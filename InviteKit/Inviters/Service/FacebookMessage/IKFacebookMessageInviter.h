//
//  IKFacebookMessageInviter.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKXMPPInviter.h"
#import "FacebookSDK.h"

@interface IKFacebookMessageInviter : IKXMPPInviter

+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)handleDidBecomeActive;
+ (void)handleWillTerminate;

@end
