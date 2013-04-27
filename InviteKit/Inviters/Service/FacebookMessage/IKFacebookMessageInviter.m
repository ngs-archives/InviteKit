//
//  IKFacebookMessageInviter.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKConfiguration.h"
#import "IKFacebookMessageInviter.h"
#import "IKInviterPrivate.h"
#import "IKItem.h"
#import "InviteKit.h"
#import "IKInviterPrivate.h"
#import "SVProgressHUD.h"
#import "XMPPFramework.h"
#import "XMPPXFacebookPlatformAuthentication.h"


static IKFacebookMessageInviter *authingFacebook=nil;
static IKFacebookMessageInviter *requestingPermisFacebook=nil;

@implementation IKFacebookMessageInviter

#pragma mark - IKInviter

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler {
  [super invite:item withCompletionHandler:handler];
  NSArray *permissions = IKCONFIG(facebookReadPermissions);
  if ([FBSession.activeSession.permissions indexOfObject:@"xmpp_login"] == NSNotFound) {
    if(FBSession.activeSession.isOpen) {
      authingFacebook = self;
      self.pendingAction = IKPendingRefreshToken;
      [SVProgressHUD showWithStatus:IKLocalizedString(@"Authenticating...")];
      [FBSession.activeSession
       requestNewReadPermissions:permissions
       completionHandler:^(FBSession *session, NSError *error) {
         if(error) {
           if(self.completionHandler) {
             [SVProgressHUD dismiss];
             self.completionHandler(error);
             self.completionHandler = nil;
           }
         } else
           [self tryPendingAction];
       }];
    } else {
      authingFacebook = self;
      self.pendingAction = IKPendingRefreshToken;
      [self openSessionWithAllowLoginUI:YES];
    }
  } else
    [self createPage:item];
}

- (void)sharePage:(ASPage *)page {
  // TODO: implement in subclass
}

- (void)dealloc {
	[FBSession.activeSession close];	// unhooks this instance from the sessionStateChanged callback
	if (authingFacebook == self) {
		authingFacebook = nil;
	}
	if (requestingPermisFacebook == self) {
		requestingPermisFacebook = nil;
	}
}

#pragma mark - Facebook

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
	// because this routine is used both for checking if we are authed and
	// initiating auth we do a quick check to see if we have been through
	// the cycle. If we don't then we'll create an infinite loop due to the
	// upstream isAuthed then trytosend logic
	
	// keep in mind that this reoutine can return TRUE even if the store creds
	// are no longer valid. For example if the user has revolked the app from
	// their profile. In this case the stored tolken look like it should work,
	// but the first request will fail
	if(FBSession.activeSession.isOpen)
		return YES;
	
  BOOL result = NO;
  FBSession *session =
	[[FBSession alloc] initWithAppID:IKCONFIG(facebookAppId)
                       permissions:IKCONFIG(facebookReadPermissions)	// FB only wants read or publish so use default read, request publish when we need it
                   urlSchemeSuffix:IKCONFIG(facebookLocalAppId)
                tokenCacheStrategy:nil];
  
  if (allowLoginUI || (session.state == FBSessionStateCreatedTokenLoaded)) {
    
		if (allowLoginUI) [SVProgressHUD showWithStatus:IKLocalizedString(@"Logging In...")];
    
    [FBSession setActiveSession:session];
    [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
            completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
              if (allowLoginUI) [SVProgressHUD dismiss];
              [self sessionStateChanged:session state:state error:error];
            }];
    result = session.isOpen;
  }
	
  return result;
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
	if(FB_ISSESSIONOPENWITHSTATE(state)){
		NSAssert(error == nil, @"InviteKit: Facebook sessionStateChanged open session, but errors?!?!");
		if(requestingPermisFacebook == self){
			// in this case, we basically want to ignore the state change because the
			// completion handler for the permission request handles the post.
			// this happens when the permissions just get extended
		}else{
			[self restoreItem];
			
			if (authingFacebook == self) {
				[self authDidFinish:true];
			}
			
			[self tryPendingAction];
		}
	}else if (FB_ISSESSIONSTATETERMINAL(state)){
		if (authingFacebook == self) {	// the state can change for a lot of reasons that are out of the login loop
			[self authDidFinish:NO];		// for exaple closing the session in dealloc.
		}else{
			// seems that if you expire the tolken that it thinks is valid it will close the session without reporting
			// errors super awesome. So look for the errors in the FBRequestHandlerCallback
		}
	}
	
	// post a notification so that custom UI can show the login state.
  [[NSNotificationCenter defaultCenter]
   postNotificationName:@"IKFacebookSessionStateChangeNotification"
   object:session];
  
  if (error) {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
  }
	if (authingFacebook == self) {
		authingFacebook = nil;
	}
}


- (void)authDidFinish:(BOOL)success
{
	[[NSNotificationCenter defaultCenter] postNotificationName:IKAuthDidFinishNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success] forKey:@"success"]];
  if(self.completionHandler) {
    NSError *error = nil;
    if(!success)
      error = [NSError errorWithDomain:@"ly.appsocial.invite-kit.auth-failure" code:100 userInfo:@{}];
    self.completionHandler(error);
  }
  
}



+ (BOOL)handleOpenURL:(NSURL *)url {
  if(!url) return NO;
	[FBSettings setDefaultAppID:IKCONFIG(facebookAppId)];
	//if app has "Application does not run in background" = YES, or was killed before it could return from Facebook SSO callback (from Safari or Facebook app)
	if (authingFacebook == nil &&
      requestingPermisFacebook == nil) {
		[FBSession.activeSession close];	// close it down because we don't know about it
		authingFacebook = [[IKFacebookMessageInviter alloc] init];	//released in sessionStateChanged
    // resend is triggered in sessionStateChanged
	}
	return [FBSession.activeSession handleOpenURL:url];
}

+ (void)handleDidBecomeActive {
	[FBSettings setDefaultAppID:IKCONFIG(facebookAppId)];
	// We need to properly handle activation of the application with regards to SSO
	//  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
	[FBSession.activeSession handleDidBecomeActive];
  
}
+ (void)handleWillTerminate {
	[FBSettings setDefaultAppID:IKCONFIG(facebookAppId)];
	// if the app is going away, we close the session object; this is a good idea because
	// things may be hanging off the session, that need releasing (completion block, etc.) and
	// other components in the app may be awaiting close notification in order to do cleanup
	[FBSession.activeSession close];
}

- (void)openSession
{
  [FBSession openActiveSessionWithReadPermissions:@[@"xmpp_login"]
                                     allowLoginUI:YES
                                completionHandler:
   ^(FBSession *session,
     FBSessionState state, NSError *error) {
     [self sessionStateChanged:session state:state error:error];
   }];
}


@end
