//
//  IKFacebookFriendPickerCell.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IKFacebookFriendPickerCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy) NSDictionary *data;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end
