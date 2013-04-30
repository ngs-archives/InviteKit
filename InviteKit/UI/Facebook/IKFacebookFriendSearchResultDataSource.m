//
//  IKFacebookFriendSearchResultDataSource.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKFacebookFriendSearchResultDataSource.h"
#import "IKFacebookFriendPickerViewController.h"
#import "IKFacebookFriendPickerCell.h"

@implementation IKFacebookFriendSearchResultDataSource
@synthesize pickerViewController = _pickerViewController;

- (id)initWithPickerViewController:(IKFacebookFriendPickerViewController *)pickerViewController {
  if(self = [super init]) {
    self.pickerViewController = pickerViewController;
  }
  return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"FriendCell";
  IKFacebookFriendPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if(!cell) {
    cell = [[IKFacebookFriendPickerCell alloc] initWithReuseIdentifier:CellIdentifier];
  }
  NSDictionary *data = self.results[indexPath.row];
  [cell setData:data];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 65.0;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  NSMutableArray *buf = [@[] mutableCopy];
  for (NSArray *section in self.pickerViewController.friends) {
    for (NSDictionary *data in section) {
      NSString *name = data[@"name"];
      if([name.lowercaseString rangeOfString:searchString.lowercaseString].location != NSNotFound) {
        [buf addObject:data];
      }
    }
  }
  self.results = buf;
  return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.pickerViewController didSelectFriend:self.results[indexPath.row]];
}

@end
