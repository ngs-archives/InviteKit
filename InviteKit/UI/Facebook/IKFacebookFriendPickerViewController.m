//
//  IKFacebookFriendPickerViewController.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKFacebookFriendPickerViewController.h"
#import "IKFacebookFriendSearchResultDataSource.h"
#import "ASAFNetworkActivityIndicatorManager.h"
#import "IKFacebookFriendPickerCell.h"
#import "FacebookSDK.h"
#import "InviteKit.h"
#import "SVProgressHUD.h"

@interface IKFacebookFriendPickerViewController ()

@property (nonatomic, strong) UISearchDisplayController *friendsSearchDisplayController;
@property (nonatomic, strong) IKFacebookFriendSearchResultDataSource *friendsSearchDataSource;

@end

@implementation IKFacebookFriendPickerViewController

- (id)initWithHandler:(IKFacebookFriendPickedHandler)handler {
  if(self = [super init]) {
    self.handler = handler;
  }
  return self;
}

- (void)didSelectFriend:(NSDictionary *)friend {
  if(self.handler)
    self.handler(friend, self);
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if(!self.friends) {
    [[ASAFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
      [[ASAFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
      if(error)
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
      else if([result[@"data"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *bFriends = @[].mutableCopy;
        NSMutableArray *bTitleIndexes = @[].mutableCopy;
        NSArray *sortedFriends = [result[@"data"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
          return [obj1[@"name"] compare:obj2[@"name"]];
        }];
        [sortedFriends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          NSString *initial = [[obj[@"name"] substringToIndex:1] uppercaseString];
          if(![bTitleIndexes containsObject:initial]) {
            [bTitleIndexes addObject:initial];
            [bFriends addObject:@[].mutableCopy];
          }
          [[bFriends lastObject] addObject:obj];
        }];
        self.friends = bFriends;
        self.titleIndexes = bTitleIndexes;
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        [searchBar sizeToFit];
        self.friendsSearchDataSource = [[IKFacebookFriendSearchResultDataSource alloc] initWithPickerViewController:self];
        self.friendsSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                                contentsController:self];
        self.friendsSearchDisplayController.searchResultsDataSource = self.friendsSearchDataSource;
        self.friendsSearchDisplayController.searchResultsDelegate = self.friendsSearchDataSource;
        self.friendsSearchDisplayController.delegate = self.friendsSearchDataSource;
        self.tableView.tableHeaderView = searchBar;
        [self.tableView reloadData];
      } else {
        [SVProgressHUD showErrorWithStatus:IKLocalizedString(@"Invalid data")];
      }
    }];
  }
}

- (UISearchDisplayController *)searchDisplayController {
  return self.friendsSearchDisplayController;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self didSelectFriend:self.friends[indexPath.section][indexPath.row]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.friends[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.titleIndexes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"FriendCell";
  IKFacebookFriendPickerCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if(!cell) {
    cell = [[IKFacebookFriendPickerCell alloc] initWithReuseIdentifier:CellIdentifier];
  }
  NSDictionary *data = self.friends[indexPath.section][indexPath.row];
  [cell setData:data];
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return self.titleIndexes[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 65.0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return self.titleIndexes;
}

@end
