//
//  InviteKit.h
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

#import <Foundation/Foundation.h>
#import "IKConfiguration.h"
#import "IKFacebookMessageInviter.h"
#import "IKItem.h"
#import <AppSociallySDK/AppSociallySDK.h>

extern NSString * const IKSendDidStartNotification;
extern NSString * const IKSendDidFinishNotification;
extern NSString * const IKSendDidFailWithErrorNotification;
extern NSString * const IKSendDidCancelNotification;
extern NSString * const IKAuthDidFinishNotification;

@interface InviteKit : NSObject

@property (nonatomic, retain) UIViewController *currentView;
@property (nonatomic, retain) UIViewController *pendingView;
@property BOOL isDismissingView;

#pragma mark -
#pragma mark View Management

+ (void)setRootViewController:(UIViewController *)vc;

/* original show method, wraps the view to UINavigationViewController prior presenting, if not already a UINavigationViewController */
- (void)showViewController:(UIViewController *)vc;
/* displays sharers with custom UI - without wrapping */
- (void)showStandaloneViewController:(UIViewController *)vc;
/* returns current top view controller to display UI from */
- (UIViewController *)rootViewForUIDisplay;

- (void)hideCurrentViewControllerAnimated:(BOOL)animated;
- (void)viewWasDismissed;

+ (UIBarStyle)barStyle;
+ (UIModalPresentationStyle)modalPresentationStyleForController:(UIViewController *)controller;
+ (UIModalTransitionStyle)modalTransitionStyleForController:(UIViewController *)controller;

#pragma mark - Singleton

+ (InviteKit *)currentHelper;
+ (NSError *)error:(NSString *)description, ...;
+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)handleDidBecomeActive;
+ (void)handleWillTerminate;

+ (AppSocially *)appsocially;
+ (NSString *)libraryBundlePath;


@end

NSString* IKLocalizedStringFormat(NSString* key);
NSString* IKLocalizedString(NSString* key, ...);
