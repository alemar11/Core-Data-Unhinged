#import "ViewController.h"
#import "DataController.h"

@interface ViewController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSTimeInterval *startTime;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
//    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
//    [fetch setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
//    
//    NSManagedObjectContext *moc = self.dataController.mainContext;
//    NSFetchedResultsController *frc = nil;
//    
//    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
//    frc.delegate = self;
//    self.fetchedResultsController = frc;
//    
//    NSError *error = nil;
//    if (![frc performFetch:&error]) {
//        NSLog(@"Error: %@\n%@", [error localizedDescription], [error userInfo]);
//        abort();
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeContext:) name:NSManagedObjectContextDidSaveNotification object:self.dataController.mainContext];
}

- (void)didChangeContext:(NSNotification*)notification
{
    id myInterestingPersonID = nil; //populate this
    id myInterestingAddressID = nil;
    
    NSDictionary *userInfo = [notification userInfo];
    NSSet *deleted = [userInfo objectForKey:NSDeletedObjectsKey];
    NSSet *inserted = [userInfo objectForKey:NSInsertedObjectsKey];
    NSSet *updated = [userInfo objectForKey:NSUpdatedObjectsKey];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"entity.name = %@ && objectID == %@", @"Person", myInterestingPersonID];
    NSPredicate *addPredicate = [NSPredicate predicateWithFormat:@"entity.name = %@ && objectID == %@", @"Address", myInterestingAddressID];
    NSPredciate *final = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, addPredicate]];
    NSSet *filtered = [deleted filteredSetUsingPredicate:final];
    if ([filtered count] > 0) {
        NSLog(@"My object was deleted");
    }
}

- (void)configureCell:(id)cell forIndexPath:(NSIndexPath*)indexPath
{
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //populate cell
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
}


#pragma mark - Fetched results controller



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self setStartTime:[NSDate timeIntervalSinceReferenceDate]];
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            id cell = [self tableView] cellForRowAtIndexPath:indexPath];
            [self configureCell:cell forIndexPath:indexPath];
            break;
            
        }
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = end - [self startTime];
    NSAssert(delta < 0.10, @"Failed");
}

@end











