//
//  AppDelegate.m
//  Pragma15
//
//  Created by Marcus Zarra on 10/9/15.
//  Copyright © 2015 Marcus Zarra. All rights reserved.
//

#import "AppDelegate.h"
#import "DataController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dataController = [[DataController alloc] init];
    // Override point for customization after application launch.
    return YES;
}

@end
