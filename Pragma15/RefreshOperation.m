//
//  RefreshOperation.m
//  Pragma15
//
//  Created by Marcus Zarra on 10/9/15.
//  Copyright © 2015 Marcus Zarra. All rights reserved.
//

#import "RefreshOperation.h"

#import "DataController.h"

@interface RefreshOperation() <NSURLSessionDataDelegate>

@property (nonatomic, weak) DataController *dataController;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation RefreshOperation

- (id)initWithDataController:(DataController*)controller
{
    if (!(self = [super init])) return nil;
    
    self.dataController = controller;
    
    return self;
}

- (void)main
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    self.data = [NSMutableData new];
    
    if ([self isCancelled]) return;
    
    NSURL *url = nil; ///Build the URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url]
    id task = [session dataTaskWithRequest:request];
    [task resume];
    
    CFRunLoopRun();
    
    if ([self isCancelled]) return;
    //I have data
    NSError *error = nil;
    NSArray *payload = [NSJSONSerialization JSONObjectWithData:self.data options:nil error:&error];
    if (payload == nil) {
        NSLog(@"Load failed: %@\n%@", [error localizedDescription], [error userInfo]);
        return;
    }
    
    if ([self isCancelled]) return;
    NSManagedObjectContext *private = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [private setParentContext:self.dataController.mainContext];
    
    [private performBlockAndWait:^{
        //my data consumption
        for (id object in payload) {
            NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MyObject" inManagedObjectContext:private];
            //load managed object
            if ([self isCancelled]) return;
        }
        NSError *error = nil;
        if (![private save:&error]) {
            NSLog(@"Failed to save private queue: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        [self.dataController.mainContext performBlock:^{
            //save
        }];
    }];
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = end - start;
    NSUInteger length = self.data.length;
    [self.networkController completedLength:length inDuration:delta];
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    [self.data appendData:data];
    if ([self isCancelled]) {
        [dataTask suspend];
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error;
{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end






