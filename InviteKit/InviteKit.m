//
//  InviteKit.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "InviteKit.h"
#import "IKConfiguration.h"
#import "Singleton.h"
#import <AppSociallySDK/AppSociallySDK.h>
#import "ASAFNetworkActivityIndicatorManager.h"

NSString * const IKSendDidStartNotification         = @"IKSendDidStartNotification";
NSString * const IKSendDidFinishNotification        = @"IKSendDidFinish";
NSString * const IKSendDidFailWithErrorNotification = @"IKSendDidFailWithError";
NSString * const IKSendDidCancelNotification        = @"IKSendDidCancel";
NSString * const IKAuthDidFinishNotification        = @"IKAuthDidFinish";

@interface InviteKit ()

@property (nonatomic, assign) UIViewController *rootViewController;
@property SEL showMethod;

@end

@implementation InviteKit

+ (void)setActivityIndicatorEnabled:(BOOL)enabled {
  [[ASAFNetworkActivityIndicatorManager sharedManager] setEnabled:enabled];
}

+ (BOOL)isActivityIndicatorEnabled {
  return [[ASAFNetworkActivityIndicatorManager sharedManager] isEnabled];
}

+ (InviteKit *)currentHelper {
  DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

#pragma mark - 

static NSString *libraryBundlePath = nil;

+ (NSString *)libraryBundlePath {
  if (libraryBundlePath == nil) {
    libraryBundlePath = [[NSBundle bundleForClass:[InviteKit class]] pathForResource:@"InviteKit" ofType:@"bundle"];
  }
  return libraryBundlePath;
}

+ (NSError *)error:(NSString *)description, ...
{
	NSDictionary *userInfo = nil;

	if (description) {
		va_list args;
		va_start(args, description);
		NSString *string = [[NSString alloc] initWithFormat:description arguments:args];
		va_end(args);

		userInfo = [NSDictionary dictionaryWithObject:string forKey:NSLocalizedDescriptionKey];
	}

	return [NSError errorWithDomain:@"sharekit" code:1 userInfo:userInfo];
}

+ (AppSocially *)appsocially {
  return [AppSocially sharedClient] ?
  [AppSocially sharedClient] :
  [AppSocially sharedClientWithAPIKey:IKCONFIG(appSociallyToken)];
}


+ (BOOL)handleOpenURL:(NSURL *)url {
  return [IKFacebookMessageInviter handleOpenURL:url];
}

+ (void)handleDidBecomeActive {
  [IKFacebookMessageInviter handleDidBecomeActive];
}

+ (void)handleWillTerminate {
  [IKFacebookMessageInviter handleWillTerminate];
}

#pragma mark - 


#pragma mark View Management

+ (void)setRootViewController:(UIViewController *)vc
{
	InviteKit *helper = [self currentHelper];
	[helper setRootViewController:vc];
}

- (UIViewController *)rootViewForUIDisplay {
  
  UIViewController *result = [self getCurrentRootViewController];
  
  // Find the top most view controller being displayed (so we can add the modal view to it and not one that is hidden)
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	while (result.modalViewController != nil) result = result.modalViewController;
#pragma clang diagnostic pop
  
  NSAssert(result, @"InviteKit: There is no view controller to display from");
	return result;
}

- (UIViewController *)getCurrentRootViewController {
  
  UIViewController *result = nil;
  
  if (self.rootViewController) // If developer provieded a root view controler, use it
  {
    
    result = self.rootViewController;
  }
  else // Try to find the root view controller programmically
	{
		// Find the top window (that is not an alert view or other window)
		UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
		if (topWindow.windowLevel != UIWindowLevelNormal)
		{
			NSArray *windows = [[UIApplication sharedApplication] windows];
			for(topWindow in windows)
			{
				if (topWindow.windowLevel == UIWindowLevelNormal)
					break;
			}
		}
		
		UIView *rootView = [[topWindow subviews] objectAtIndex:0];
		id nextResponder = [rootView nextResponder];
		
		if ([nextResponder isKindOfClass:[UIViewController class]])
			result = nextResponder;
		else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
      result = topWindow.rootViewController;
		else
			NSAssert(NO, @"InviteKit: Could not find a root view controller.  You can assign one manually by calling [[InviteKit currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
	}
  return result;
}

- (void)showViewController:(UIViewController *)vc
{
  self.showMethod = @selector(showViewController:);
  
  BOOL isHidingPreviousView = [self hidePreviousView:vc];
  if (isHidingPreviousView) return;
  
  // Wrap the view in a nav controller if not already. Used for system views, such as share menu and share forms. BEWARE: this has to be called AFTER hiding previous. Sometimes hiding and presenting view is the same sharer, but with different SHKFormController on top (auth vs edit)
  
  NSAssert(vc.parentViewController == nil, @"vc must not be in the view hierarchy now"); //ios4 and older
  
  if ([UIViewController instancesRespondToSelector:@selector(presentingViewController)]) {
    NSAssert(vc.presentingViewController == nil, @"vc must not be in the view hierarchy now"); //ios5+
  }
  
	if (![vc isKindOfClass:[UINavigationController class]]) vc = [[UINavigationController alloc] initWithRootViewController:vc];
  
  [(UINavigationController *)vc navigationBar].barStyle = [InviteKit barStyle];
  [(UINavigationController *)vc toolbar].barStyle = [InviteKit barStyle];
  [(UINavigationController *)vc navigationBar].tintColor = IKCONFIG_WITH_ARGUMENT(barTintForView:,vc);
  
  [self presentVC:vc];
}

/* method for sharers with custom UI, e.g. all social.framework sharers, print etc */
- (void)showStandaloneViewController:(UIViewController *)vc {
  
  self.showMethod = @selector(presentVC:);
  
  BOOL isHidingPreviousView = [self hidePreviousView:vc];
  if (isHidingPreviousView) return;
  
  [self presentVC:vc];
}

- (void)presentVC:(UIViewController *)vc {
  
  BOOL isSocialOrTwitterComposeVc = [vc respondsToSelector:@selector(setInitialText:)];
  
  if ([vc respondsToSelector:@selector(modalPresentationStyle)] && !isSocialOrTwitterComposeVc)
    vc.modalPresentationStyle = [InviteKit modalPresentationStyleForController:vc];
  
  if ([vc respondsToSelector:@selector(modalTransitionStyle)] && !isSocialOrTwitterComposeVc)
    vc.modalTransitionStyle = [InviteKit modalTransitionStyleForController:vc];
  
  UIViewController *topViewController = [self rootViewForUIDisplay];
  
  if ([UIViewController instancesRespondToSelector:@selector(presentViewController:animated:completion:)]) {
    [topViewController presentViewController:vc animated:YES completion:nil];
  } else {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [topViewController presentModalViewController:vc animated:YES];
#pragma clang diagnostic pop
  }
  
  self.currentView = vc;
	self.pendingView = nil;
}

- (BOOL)hidePreviousView:(UIViewController *)VCToShow {
  
  // If a view is already being shown, hide it, and then try again
	if (self.currentView != nil) {
    
		self.pendingView = VCToShow;
		[self hideCurrentViewControllerAnimated:YES];
    return YES;
    
  }
  return NO;
}

- (void)hideCurrentViewController
{
	[self hideCurrentViewControllerAnimated:YES];
}

- (void)hideCurrentViewControllerAnimated:(BOOL)animated
{
	if (self.isDismissingView)
		return;
	
	if (self.currentView != nil)
	{
		// Dismiss the modal view
		if ([self.currentView presentingViewController])
		{
			self.isDismissingView = YES;
      [[self.currentView presentingViewController] dismissViewControllerAnimated:animated completion:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          [self viewWasDismissed];
        }];
      }];
    }
		else
    {
			self.currentView = nil;
    }
	}
}

- (void)showPendingView
{
  if (self.pendingView)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:self.showMethod withObject:self.pendingView];
#pragma clang diagnostic pop
}

- (void)viewWasDismissed
{
	self.isDismissingView = NO;
	
	if (self.currentView != nil)
		self.currentView = nil;
	
	if (self.pendingView)
	{
		// This is an ugly way to do it, but it works.
		// There seems to be an issue chaining modal views otherwise
		// See: http://github.com/ideashower/ShareKit/issues#issue/24
		[self performSelector:@selector(showPendingView) withObject:nil afterDelay:0.02];
		return;
	}
}

+ (UIBarStyle)barStyle
{
	if ([IKCONFIG(barStyle) isEqualToString:@"UIBarStyleBlack"])
		return UIBarStyleBlack;
	
	else if ([IKCONFIG(barStyle) isEqualToString:@"UIBarStyleBlackOpaque"])
		return UIBarStyleBlackOpaque;
	
	else if ([IKCONFIG(barStyle) isEqualToString:@"UIBarStyleBlackTranslucent"])
		return UIBarStyleBlackTranslucent;
	
	return UIBarStyleDefault;
}

+ (UIModalPresentationStyle)modalPresentationStyleForController:(UIViewController *)controller
{
	NSString *styleString = IKCONFIG_WITH_ARGUMENT(modalPresentationStyleForController:, controller);
	
	if ([styleString isEqualToString:@"UIModalPresentationFullScreen"])
		return UIModalPresentationFullScreen;
	
	else if ([styleString isEqualToString:@"UIModalPresentationPageSheet"])
		return UIModalPresentationPageSheet;
	
	else if ([styleString isEqualToString:@"UIModalPresentationFormSheet"])
		return UIModalPresentationFormSheet;
	
	return UIModalPresentationCurrentContext;
}

+ (UIModalTransitionStyle)modalTransitionStyleForController:(UIViewController *)controller
{
  NSString *transitionString = IKCONFIG_WITH_ARGUMENT(modalTransitionStyleForController:, controller);
  
	if ([transitionString isEqualToString:@"UIModalTransitionStyleFlipHorizontal"])
		return UIModalTransitionStyleFlipHorizontal;
	
	else if ([transitionString isEqualToString:@"UIModalTransitionStyleCrossDissolve"])
		return UIModalTransitionStyleCrossDissolve;
	
	else if ([transitionString isEqualToString:@"UIModalTransitionStylePartialCurl"])
		return UIModalTransitionStylePartialCurl;
	
	return UIModalTransitionStyleCoverVertical;
}



@end


NSString* IKLocalizedStringFormat(NSString* key) {
  static NSBundle* bundle = nil;
  if (nil == bundle) {
    
    NSString *path = nil;
    if ([IKCONFIG(isUsingCocoaPods) boolValue]) {
      path = [InviteKit libraryBundlePath];
    } else {
      path = [[InviteKit libraryBundlePath] stringByAppendingPathComponent:@"InviteKit.bundle"];
    }
    
    bundle = [NSBundle bundleWithPath:path];
    NSString *msg = [NSString stringWithFormat:@"bundle not found at %@", path];
    NSCAssert(bundle != nil, msg);
  }
  return [bundle localizedStringForKey:key value:key table:nil];
}

NSString* IKLocalizedString(NSString* key, ...) {
	// Localize the format
	NSString *localizedStringFormat = IKLocalizedStringFormat(key);
	
	va_list args;
  va_start(args, key);
  NSString *string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
  va_end(args);
	
	return string;
}


