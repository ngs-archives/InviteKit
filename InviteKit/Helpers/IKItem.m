//
//  IKItem.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKItem.h"

@implementation IKItem

+ (id)itemWithProperties:(NSDictionary *)properties {
  IKItem *item = [[self alloc] init];
  item.properties = properties;
  return item;
}

@end
