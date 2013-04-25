//
//  IKFacebookMessageInviter.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKConfiguration.h"
#import "AppSociallySDK.h"
#import "IKFacebookMessageInviter.h"
#import "IKInviterPrivate.h"
#import "IKItem.h"
#import "InviteKit.h"
#import "SVProgressHUD.h"
#import "XMPPFramework.h"
#import "XMPPXFacebookPlatformAuthentication.h"


static IKFacebookMessageInviter *authingFacebook=nil;
static IKFacebookMessageInviter *requestingPermisFacebook=nil;


@interface IKFacebookMessageInviter ()

@property (nonatomic, copy) IKInviteCompletionHandler completionHandler;

@end

@implementation IKFacebookMessageInviter

#pragma mark - IKInviter

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler {
  self.completionHandler = handler;
  NSArray *permissions = IKCONFIG(facebookWritePermissions);
  if ([FBSession.activeSession.permissions indexOfObject:@"xmpp_login"] == NSNotFound) {
    [SVProgressHUD showWithStatus:IKLocalizedString(@"Authenticating...")];
    [FBSession.activeSession
     requestNewPublishPermissions:permissions
     defaultAudience:FBSessionDefaultAudienceFriends
     completionHandler:^(FBSession *session, NSError *error) {
       if(error) {
         if(self.completionHandler) {
           self.completionHandler(error);
           self.completionHandler = nil;
         }
       } else
         [self createPage:item];
     }];
  } else
    [self createPage:item];
}

- (void)createPage:(IKItem *)item {
  [[InviteKit appsocially]
   createPageWithTemplate:IKCONFIG(inviteTemplateName)
   withData:item.properties
   downloadContents:NO
   completionHandler:^(ASPage *page, NSError *error) {
     
   }];
  
}

- (void)dealloc {
  
}

#pragma mark - Facebook

+ (BOOL)handleOpenURL:(NSURL *)url {
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

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
  switch (state) {
    case FBSessionStateOpen: {
      
    }
    case FBSessionStateClosed:
    case FBSessionStateClosedLoginFailed: {
      [FBSession.activeSession closeAndClearTokenInformation];
    }
      break;
    default:
      break;
  }
  
  if (error) {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
  }
}

- (void)openSession
{
  [FBSession openActiveSessionWithReadPermissions:nil
                                     allowLoginUI:YES
                                completionHandler:
   ^(FBSession *session,
     FBSessionState state, NSError *error) {
     [self sessionStateChanged:session state:state error:error];
   }];
}


@end
