//
//  IKFacebookFriendPickerCell.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKFacebookFriendPickerCell.h"
#import "UIImageView+AFNetworking.h"

@implementation IKFacebookFriendPickerCell
@synthesize data = _data;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  return self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat l = 65;
  CGFloat w = self.contentView.frame.size.width - l - 15;
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.clipsToBounds = YES;
  self.imageView.frame = CGRectMake(5, 5, 50, 50);
  if(nil==self.activityIndicatorView) {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.activityIndicatorView stopAnimating];
    [self.contentView addSubview:self.activityIndicatorView];
  }
  self.activityIndicatorView.center = self.imageView.center;
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.textLabel.frame = CGRectMake(l, self.textLabel.frame.origin.y, w, self.textLabel.frame.size.height);
  [self.textLabel setMinimumScaleFactor:0.7];
  self.textLabel.adjustsFontSizeToFitWidth = YES;
  self.detailTextLabel.frame = CGRectMake(l, self.detailTextLabel.frame.origin.y, w, self.detailTextLabel.frame.size.height);
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setData:(NSDictionary *)data {
  _data = [data copy];
  NSString *name = data[@"name"];
  NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", data[@"id"]]];

  __block IKFacebookFriendPickerCell *that = self;
  [self.textLabel setText:name];
  [self.activityIndicatorView startAnimating];
  self.imageView.hidden = YES;
  [self.imageView
   setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL]
   placeholderImage:nil
   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
     [that.activityIndicatorView stopAnimating];
     that.imageView.image = image;
     that.imageView.hidden = NO;
     [that setNeedsLayout];
   }
   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     [that.activityIndicatorView stopAnimating];
     [that setNeedsLayout];
   }];
  [self setNeedsLayout];
}

@end
