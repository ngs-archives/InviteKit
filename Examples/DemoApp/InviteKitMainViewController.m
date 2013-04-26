//
//  InviteKitMainViewController.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "InviteKitMainViewController.h"
#import "InviteKit.h"

@implementation InviteKitMainViewController

- (IBAction)invite:(id)sender {
  IKItem *item = [IKItem itemWithProperties:@{}];
  [IKFacebookMessageInviter invite:item withCompletionHandler:^(NSError *error) {
    
  }];
}

@end
