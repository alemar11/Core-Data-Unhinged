//
//  RefreshOperation.h
//  Pragma15
//
//  Created by Marcus Zarra on 10/9/15.
//  Copyright © 2015 Marcus Zarra. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataController;

@interface RefreshOperation : NSOperation

- (id)initWithDataController:(DataController*)controller;

@end
