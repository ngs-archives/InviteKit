//
//  IKItem.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IKItem : NSObject

@property (nonatomic, copy) NSDictionary *properties;

+ (id)itemWithProperties:(NSDictionary *)properties;

@end
