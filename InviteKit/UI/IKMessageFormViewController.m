//
//  IKMessageFormViewController.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKMessageFormViewController.h"

@interface IKMessageFormViewController ()

@end

@implementation IKMessageFormViewController

- (id)initWithCompletionHandler:(IKMessageFormCompletionHandler)completionHandler {
  if(self = [super initWithNibName:nil bundle:nil]) {
    self.completionHandler = completionHandler;
  }
  return self;
}

@end
