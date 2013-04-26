//
//  IKInviter.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
  IKPendingNone,
  IKPendingShare, //when SInviteit detects invalid credentials BEFORE user sends. User continues editing share content after login.
  IKPendingRefreshToken, //when OAuth token expires
  IKPendingSend, //when InviteKit detects invalid credentials AFTER user sends. Item is resent without showing edit dialogue (user edited already).
} IKInviterPendingAction;


@class IKItem, ASPage;

typedef void (^IKInviteCompletionHandler)(NSError *error);

@interface IKInviter : NSObject

@property (strong, nonatomic) IKItem *item;
@property (assign, nonatomic) IKInviterPendingAction pendingAction;
@property (nonatomic, copy) IKInviteCompletionHandler completionHandler;

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler;
+ (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler;
- (BOOL)restoreItem;
+ (void)clearSavedItem;
- (void)tryPendingAction;
- (void)sharePage:(ASPage *)page;

@end
