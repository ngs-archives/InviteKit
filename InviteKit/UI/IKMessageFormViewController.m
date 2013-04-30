//
//  IKMessageFormViewController.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/29/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKMessageFormViewController.h"
#import "InviteKit.h"

@interface IKMessageFormViewController ()

@end

@implementation IKMessageFormViewController
@synthesize textView = _textView
, doneButtonItem = _doneButtonItem
, cancelButtonItem = _cancelButtonItem
;


- (id)initWithCompletionHandler:(IKMessageFormCompletionHandler)completionHandler {
  if(self = [super initWithNibName:nil bundle:nil]) {
    self.completionHandler = completionHandler;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
  }
  return self;
}
#pragma mark - Accessors

- (UITextView *)textView {
  if(nil==_textView) {
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:_textView];
  }
  return _textView;
}

- (UIBarButtonItem *)doneButtonItem {
  if(nil==_doneButtonItem) {
    _doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:IKLocalizedString(@"Send")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(done:)];
  }
  return _doneButtonItem;
}

- (UIBarButtonItem *)cancelButtonItem {
  if(nil==_cancelButtonItem) {
    _cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:IKLocalizedString(@"Cancel")
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(cancel:)];
  }
  return _cancelButtonItem;
}

#pragma mark - Actions

- (void)done:(id)sender {
  [self.textView resignFirstResponder];
  if(self.completionHandler && self.completionHandler(self, NO)) {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
  } else {
    [self dismissViewControllerAnimated:YES completion:NULL];
  }
}

- (void)cancel:(id)sender {
  if(self.navigationController.viewControllers.count == 1)
    [self dismissViewControllerAnimated:YES completion:NULL];
  else
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self textView];
  self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
  self.navigationItem.rightBarButtonItem = self.doneButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification object:nil];
  self.doneButtonItem.enabled = self.textView.text && [self.textView.text length] > 0;
  [self.textView becomeFirstResponder];

}

- (void)viewWillDisappear:(BOOL)animated {
  [self.view endEditing:YES];
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification  object:nil];
  self.doneButtonItem.enabled = self.textView.text && [self.textView.text length] > 0;
}

#pragma mark - Layout

-(void) keyboardWillShow:(NSNotification *)aNotification {
  [self moveTextViewForKeyboard:aNotification up:YES];
}

-(void) keyboardWillHide:(NSNotification *)aNotification {
  [self moveTextViewForKeyboard:aNotification up:NO];
}

- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up {
  NSDictionary* userInfo = [aNotification userInfo];
  NSTimeInterval animationDuration;
  UIViewAnimationCurve animationCurve;
  CGRect keyboardEndFrame;
  [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
  [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
  [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:animationDuration];
  [UIView setAnimationCurve:animationCurve];

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
  CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
  CGFloat h = screenRect.size.height - statusBarFrame.size.height - navigationBarFrame.size.height;
  CGRect newFrame = CGRectMake(0, 0, screenRect.size.width, h);
  CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
  if(up) {
    newFrame.size.height -= keyboardFrame.size.height;
  }
  self.view.frame = newFrame;
  [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  NSString *after = [textView.text stringByReplacingCharactersInRange:range withString:text];
  if([after rangeOfString:@"\n"].location != NSNotFound || after.length > 90) return NO;
  self.doneButtonItem.enabled = after && after.length > 0;
  return YES;
}

@end
