//
//  DefaultIKConfigurator.m
//  InviteKit
//
//  Created by Atsushi Nagase on 4/24/13.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DefaultIKConfigurator.h"

@implementation DefaultIKConfigurator

- (NSString *)appSociallyToken {
  return nil;
}

- (NSString*)facebookAppId {
  return nil;
}

- (NSString *)facebookLocalAppId {
  return nil;
}

//Change if your app needs some special Facebook permissions only. In most cases you can leave it as it is.

// new with the 3.1 SDK facebook wants you to request read and publish permissions separatly. If you don't
// you won't get a smooth login/auth flow. Since InviteKit does not require any read permissions.
- (NSArray *)facebookWritePermissions {
  return @[];
}
- (NSArray *)facebookReadPermissions {
  return @[@"xmpp_login"];
}


/* cocoaPods can not build InviteKit.bundle resource target. This switches InviteKit to use resources directly. If someone knows how to build a resource target with cocoapods, please submit a pull request, so we can get rid of languages InviteKit.bundle and put languages directly to resource target */
- (NSNumber *)isUsingCocoaPods {
  return @NO;
}

- (NSString *)inviteTemplateName {
  return @"webpage";
}

@end
