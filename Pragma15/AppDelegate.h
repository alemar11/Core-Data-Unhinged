//
//  AppDelegate.h
//  Pragma15
//
//  Created by Marcus Zarra on 10/9/15.
//  Copyright © 2015 Marcus Zarra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DataController *dataController;

@end

