//
//  IKConfiguration.m
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

#import "IKConfiguration.h"
#import "DefaultIKConfigurator.h"

@interface IKConfiguration ()

@property (readonly, retain) DefaultIKConfigurator *configurator;

- (id)initWithConfigurator:(DefaultIKConfigurator*)config;

@end

static IKConfiguration *sharedInstance = nil;

@implementation IKConfiguration
@synthesize configurator;

#pragma mark - Instance methods

- (id)configurationValue:(NSString*)selector withObject:(id)object
{
  
	SEL sel = NSSelectorFromString(selector);
	if ([self.configurator respondsToSelector:sel]) {
		id value;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (object) {
      value = [self.configurator performSelector:sel withObject:object];
    } else {
      value = [self.configurator performSelector:sel];
    }
#pragma clang diagnostic pop
    
		if (value) {
			//SHKLog(@"Found configuration value for %@: %@", selector, [value description]);
			return value;
		}
	}
  
	//SHKLog(@"Configuration value is nil or not found for %@.", selector);
	return nil;
}

#pragma mark -
#pragma mark Singleton methods


+ (IKConfiguration *)sharedInstance {
  @synchronized(self)
  {
    if (sharedInstance == nil) {
      [NSException raise:@"IllegalStateException" format:@"InviteKit must be configured before use. Use your subclass of DefaultIKConfigurator, for more info see https://github.com/appsocially/InviteKit. Example: InviteKitDemoConfigurator in the demo app"];
    }
  }
  return sharedInstance;
}

+ (IKConfiguration *)sharedInstanceWithConfigurator:(DefaultIKConfigurator *)config {
  @synchronized(self)
  {
		if (sharedInstance != nil) {
			[NSException raise:@"IllegalStateException" format:@"SHKConfiguration has already been configured with a delegate."];
		}
		sharedInstance = [[IKConfiguration alloc] initWithConfigurator:config];
  }
  return sharedInstance;
}

#pragma mark - Singleton implementations

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;  // assignment and return on first allocation
    }
  }
  return nil; // on subsequent allocation attempts return nil
}

- (id)initWithConfigurator:(DefaultIKConfigurator*)config {
  if ((self = [super init])) {
		configurator = config;
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

@end
