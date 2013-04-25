//
//  IKInviter.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKInviter.h"

@implementation IKInviter

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler {
  [NSException
   raise:@"Not implemented"
   format:@"invite:withCompletionHandler: is not implmented in %@", NSStringFromClass(self.class)];
}

@end
