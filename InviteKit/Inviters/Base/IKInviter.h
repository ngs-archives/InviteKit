//
//  IKInviter.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IKItem;

typedef void (^IKInviteCompletionHandler)(NSError *error);

@interface IKInviter : NSObject

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler;

@end
