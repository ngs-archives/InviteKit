//
//  IKXMPPInviter.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "InviteKit.h"
#import "IKXMPPInviter.h"
#import "XMPPFramework.h"
#import "SVProgressHUD.h"
#import "IKMessageFormViewController.h"

@interface IKXMPPInviter ()

@property (nonatomic, assign) BOOL sent;

@end

@implementation IKXMPPInviter

- (void)didSendInvitation {
  [self disconnect];
}


- (void)disconnect {
  [self.xmppStream disconnect];
}

- (void)sharePage:(ASPage *)page {
  self.pendingPage = page;
  [SVProgressHUD showWithStatus:IKLocalizedString(@"Sending message...") maskType:SVProgressHUDMaskTypeGradient];
  NSError *error = nil;
  [self.xmppStream connect:&error];
}

#pragma mark - XMPP

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
  if(self.pendingReceiverId) {
    DDXMLElement *e = [DDXMLElement elementWithName:@"message" xmlns:@"jabber:client"];
    [e addAttributeWithName:@"to" stringValue:self.pendingReceiverId];
    [e addChild:[DDXMLElement elementWithName:@"body" stringValue:[NSString stringWithFormat:@"%@ %@", self.pendingPage.message, self.pendingPage.URL.absoluteString]]];
    if(self.pendingPage.data && self.pendingPage.data[@"subject"])
      [e addChild:[DDXMLElement elementWithName:@"subject" stringValue:self.pendingPage.data[@"subject"]]];
    XMPPElementReceipt *recp = nil;
    [self.xmppStream sendElement:e andGetReceipt:&recp];
    self.pendingReceiverId = nil;
  }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
  [self disconnect];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
  UINavigationController *nvc = nil;
  if([[[InviteKit currentHelper] currentView] isKindOfClass:[UINavigationController class]])
    nvc = (UINavigationController *)[[InviteKit currentHelper] currentView];
  if(error) {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    if([nvc.topViewController isKindOfClass:[IKMessageFormViewController class]]) {
      IKMessageFormViewController *messageVC = (IKMessageFormViewController *)nvc.topViewController;
      [messageVC.navigationItem.rightBarButtonItem setEnabled:YES];
      [messageVC.navigationItem.leftBarButtonItem setEnabled:YES];
    } else {
      [nvc popToRootViewControllerAnimated:YES];
    }
  } else {
    [nvc popToRootViewControllerAnimated:YES];
    [SVProgressHUD showSuccessWithStatus:IKLocalizedString(@"Sent!")];
  }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
  [self disconnect];
  [self didSendInvitation];
}

@end
