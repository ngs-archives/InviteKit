//
//  IKXMPPInviter.h
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "IKInviter.h"

@class XMPPStream;
@interface IKXMPPInviter : IKInviter

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

- (void)disconnect;

@end
