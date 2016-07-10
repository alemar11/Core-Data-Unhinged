//-com.apple.CoreData.ConcurrencyDebug 1

#import "DataController.h"
#import "RefreshOperation.h"

@interface DataController()

@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSManagedObjectContext *writerContext;

- (void)initializeCoreData;

@end

@implementation DataController

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.networkQueue = [[NSOperationQueue alloc] init];
    [self.networkQueue addObserver:self forKeyPath:@"operationCount" options:0 context:null];
    
    [self initializeCoreData];
    
    return self;
}


- (void)initializeCoreData
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"model" withExtension:@"momdmsz"];
    NSAssert(modelURL != nil, @"Failed to find model");
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    self.writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.writerContext.persistentStoreCoordinator = psc;

    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainContext.parentContext = self.writerContext;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSURL *docURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
        NSAssert(docURL != nil, @"Failed to find documents directory");
        NSURL *storeURL = [docURL URLByAppendingPathComponent:@"Data.sqlite"];
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        [options setValue:@(YES) forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:@(YES) forKey:NSInferMappingModelAutomaticallyOption];
        
        NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL options:nil error:&error];
        if (![mom isConfiguration:@"Recoverable" compatibleWithStoreMetadata:metadata]) {
            //migration event
        }
        
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Recoverable" URL:storeURL options:options error:&error];
        if (store == nil) {
            NSLog(@"Failed: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
        NSURL *unrecoverableURL = [docURL URLByAppendingPathComponent:@"Fred.sqlite"];
        store = [psc addPersistentStoreWithType:NSBinaryStoreType configuration:@"Unrecoverable" URL:unrecoverableURL options:options error:&error];
        if (store == nil) {
            NSLog(@"Failed: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
    });
}

- (void)save
{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self save];
        })
        return;
    }
    NSError *error = nil;
    if ([self.mainContext hasChanges]) {
        if (![self.mainContext save:&error]) {
            NSLog(@"Failed: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc performBlockAndWait:^{
        //manipulate data
        
        [moc performBlockAndWait:^{
            NSError *error = nil;
            if (![moc save:&error]) {
                NSLog(@"Writer context failed: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
        }];
    }];
    
    
    
    [self.writerContext performBlock:^{
        if (![self.writerContext hasChanges]) {
            return;
        }
        NSError *error = nil;
        if (![self.writerContext save:&error]) {
            NSLog(@"Writer context failed: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }];
}

- (void)refresh
{
    for (id op in self.networkQueue.operations) {
        if ([op isKindOfClass:[RefreshOperation class]]) return;
    }
    
    RefreshOperation *op = [[RefreshOperation alloc] initWithDataController:self];
    [self.networkQueue addOperation:op];
}

- (void)refresh:(nullable void (^)(void))block
{
    for (id op in self.networkQueue.operations) {
        if ([op isKindOfClass:[RefreshOperation class]]) return;
    }
    
    RefreshOperation *op = [[RefreshOperation alloc] initWithDataController:self];
    [op setCompletionBlock:block];
    [self.networkQueue addOperation:op];
}

@end







