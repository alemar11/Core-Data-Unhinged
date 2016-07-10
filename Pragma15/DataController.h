//
//  DataController.h
//  Pragma15
//
//  Created by Marcus Zarra on 10/9/15.
//  Copyright © 2015 Marcus Zarra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataController : NSObject

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

- (void)save;

@end
