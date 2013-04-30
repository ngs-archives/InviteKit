//
//  IKXMPPInviter.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKInviter.h"
#import "XMPPStream.h"

@class ASPage;
@interface IKXMPPInviter : IKInviter<XMPPStreamDelegate>

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong) ASPage *pendingPage;
@property (nonatomic, strong) NSString *pendingReceiverId;

- (void)disconnect;

@end
