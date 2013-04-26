//
//  InviteKit.m
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

#import "InviteKit.h"
#import "IKConfiguration.h"
#import "AppSocially.h"

NSString * const IKSendDidStartNotification         = @"IKSendDidStartNotification";
NSString * const IKSendDidFinishNotification        = @"IKSendDidFinish";
NSString * const IKSendDidFailWithErrorNotification = @"IKSendDidFailWithError";
NSString * const IKSendDidCancelNotification        = @"IKSendDidCancel";
NSString * const IKAuthDidFinishNotification        = @"IKAuthDidFinish";

@implementation InviteKit


static NSString *libraryBundlePath = nil;

+ (NSString *)libraryBundlePath {
  if (libraryBundlePath == nil) {
    libraryBundlePath = [[NSBundle bundleForClass:[InviteKit class]] pathForResource:@"InviteKit" ofType:@"bundle"];
  }
  return libraryBundlePath;
}

+ (AppSocially *)appsocially {
  return [AppSocially sharedClient] ?
  [AppSocially sharedClient] :
  [AppSocially sharedClientWithAPIKey:IKCONFIG(appSociallyToken)];
}


+ (BOOL)handleOpenURL:(NSURL *)url {
  return [IKFacebookMessageInviter handleOpenURL:url];
}

+ (void)handleDidBecomeActive {
  [IKFacebookMessageInviter handleDidBecomeActive];
}

+ (void)handleWillTerminate {
  [IKFacebookMessageInviter handleWillTerminate];
}


@end


NSString* IKLocalizedStringFormat(NSString* key) {
  static NSBundle* bundle = nil;
  if (nil == bundle) {
    
    NSString *path = nil;
    if ([IKCONFIG(isUsingCocoaPods) boolValue]) {
      path = [InviteKit libraryBundlePath];
    } else {
      path = [[InviteKit libraryBundlePath] stringByAppendingPathComponent:@"InviteKit.bundle"];
    }
    
    bundle = [NSBundle bundleWithPath:path];
    NSString *msg = [NSString stringWithFormat:@"bundle not found at %@", path];
    NSCAssert(bundle != nil, msg);
  }
  return [bundle localizedStringForKey:key value:key table:nil];
}

NSString* IKLocalizedString(NSString* key, ...) {
	// Localize the format
	NSString *localizedStringFormat = IKLocalizedStringFormat(key);
	
	va_list args;
  va_start(args, key);
  NSString *string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
  va_end(args);
	
	return string;
}


