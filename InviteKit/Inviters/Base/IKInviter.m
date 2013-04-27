//
//  IKInviter.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKInviter.h"
#import "IKInviterPrivate.h"
#import "InviteKit.h"
#import <AppSociallySDK/AppSociallySDK.h>
#import "SVProgressHUD.h"

static NSString *const kIKStoredItemKey = @"kIKStoredItem";
static NSString *const kIKStoredActionKey = @"kIKStoredAction";
static NSString *const kIKStoredShareInfoKey = @"kIKStoredShareInfo";

@implementation IKInviter

+ (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler {
  return [[[self alloc] init] invite:item withCompletionHandler:handler];
}

- (void)invite:(IKItem *)item withCompletionHandler:(IKInviteCompletionHandler)handler {
  self.completionHandler = handler;
  self.item = item;
}

- (void)createPage:(IKItem *)item {
  [SVProgressHUD showWithStatus:IKLocalizedString(@"Creating page...")];
  [[InviteKit appsocially]
   createPageWithTemplate:IKCONFIG(inviteTemplateName)
   withData:item.properties
   downloadContents:NO
   completionHandler:^(ASPage *page, NSError *error) {
     if(error)
       [SVProgressHUD showErrorWithStatus:error.localizedDescription];
     else {
       [SVProgressHUD dismiss];
       [self sharePage:page];
     }
   }];
}

- (void)sharePage:(ASPage *)page {
  // TODO: implement in subclass
}

#pragma mark - Share Item temporary save

- (BOOL)restoreItem {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *storedShareInfo = [defaults objectForKey:kIKStoredShareInfoKey];
  
	if (storedShareInfo)
	{
    self.item = [NSKeyedUnarchiver unarchiveObjectWithData:[storedShareInfo objectForKey:kIKStoredItemKey]];
		self.pendingAction = [[storedShareInfo objectForKey:kIKStoredActionKey] intValue];
    [[self class] clearSavedItem];
  }
	return storedShareInfo != nil;
}

+ (void)clearSavedItem {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:kIKStoredShareInfoKey];
  [defaults synchronize];
}


#pragma mark -
#pragma mark Pending Actions

- (void)tryPendingAction {
  if(self.pendingAction != IKPendingNone) {
    [self invite:self.item withCompletionHandler:self.completionHandler];
    self.pendingAction = IKPendingNone;
  }
}

@end


