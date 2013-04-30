//
//  IKFacebookFriendSearchResultDataSource.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IKFacebookFriendPickerViewController;
@interface IKFacebookFriendSearchResultDataSource : NSObject<UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

- (id)initWithPickerViewController:(IKFacebookFriendPickerViewController *)pickerViewController;

@property (nonatomic, copy) NSArray *results;
@property (nonatomic, unsafe_unretained) IKFacebookFriendPickerViewController *pickerViewController;

@end
