//
//  IKFacebookFriendPickerViewController.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IKFacebookFriendPickerViewController;
typedef void (^IKFacebookFriendPickedHandler)(NSDictionary *friend, IKFacebookFriendPickerViewController *viewController);

@interface IKFacebookFriendPickerViewController : UITableViewController

- (id)initWithHandler:(IKFacebookFriendPickedHandler)handler;
- (void)didSelectFriend:(NSDictionary *)friend;

@property (nonatomic, copy) NSArray *friends;
@property (nonatomic, copy) IKFacebookFriendPickedHandler handler;
@property (nonatomic, copy) NSArray *titleIndexes;

@end
