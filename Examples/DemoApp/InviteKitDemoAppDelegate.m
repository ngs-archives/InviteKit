//
//  InviteKitDemoAppDelegate.m
//  DemoApp
//
//  Created by Atsushi Nagase on 4/24/13.
//  Copyright (c) 2013 AppSocially Inc. All rights reserved.
//

#import "InviteKitDemoAppDelegate.h"
#import "InviteKit.h"
#import "InviteDemoAppConfigurator.h"

@implementation InviteKitDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  DefaultIKConfigurator *configurator = [[InviteDemoAppConfigurator alloc] init];
  [IKConfiguration sharedInstanceWithConfigurator:configurator];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [InviteKit handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [InviteKit handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [InviteKit handleWillTerminate];
}

@end
