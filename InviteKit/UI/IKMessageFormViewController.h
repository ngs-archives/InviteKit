//
//  IKMessageFormViewController.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IKMessageFormViewController;
typedef BOOL (^IKMessageFormCompletionHandler)(IKMessageFormViewController *viewController, BOOL canceled);

@interface IKMessageFormViewController : UIViewController<UITextViewDelegate>

- (id)initWithCompletionHandler:(IKMessageFormCompletionHandler)completionHandler;

@property (nonatomic, copy) IKMessageFormCompletionHandler completionHandler;
@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, readonly) UIBarButtonItem *doneButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *cancelButtonItem;

@end
