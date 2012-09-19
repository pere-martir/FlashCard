//
//  FCMasterViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Parse/Parse.h>
#import "FCMasterViewController.h"
#import "FCDetailViewController.h"
#import "Entry.h"

@interface FCMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FCMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize prefs = _prefs;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (FCDetailViewController *)[self.splitViewController.viewControllers lastObject];
    
    if (!_kLangFullNames) {
        _kLangFullNames = [NSDictionary dictionaryWithObjectsAndKeys: 
                           @"Castellano", @"es",
                           @"Italiano", @"it", nil];
    }
    
    NSString *_lang = [self.prefs stringForKey:@"lang"];
    self.title = [_kLangFullNames valueForKey:_lang];
    
    NSError* error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self showLastUpdate];
}


- (void) syncWithWebService
{
    NSAssert([PFUser currentUser], @"No logined user");

    NSString *lang = [self.prefs objectForKey:@"lang"];
    NSDictionary *lastUpdatedAt = [self.prefs dictionaryForKey:@"lastUpdatedAt"];

    PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
    [query whereKey:@"updatedAt" greaterThan:[lastUpdatedAt objectForKey:lang]];
    [query whereKey:@"lang" equalTo:lang];
    
    // TODO: Use "paged-index" to fetch all - 
    //  http://engineering.linkedin.com/voldemort/voldemort-collections-iterating-over-key-value-store
    query.limit = 1000; 
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *remoteEntries, NSError *error) {
        if (!error) {
            NSLog(@"Remote entries: %d", remoteEntries.count);
            if ([remoteEntries count] == 0) return;
    
            NSArray *arrayOfIds = [remoteEntries valueForKey:@"objectId"]; // NSString* ?
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Entry"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", arrayOfIds];            
            [fetchRequest setPredicate:predicate];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                              [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
            __block NSArray *localEntries = nil;
            NSError *error = nil;
            localEntries = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            NSLog(@"Local entries: %d", localEntries.count);

            int currentIndex = 0;
            
            for (PFObject *remoteEntry in remoteEntries) {
                Entry *localEntry = nil;
                if ([localEntries count] > currentIndex) {
                    localEntry = (Entry *)[localEntries objectAtIndex:currentIndex];
                    
                    NSString * objectId = localEntry.objectId; //[localEntry valueForKey:@"objectId"];
                    if ([objectId isEqualToString: [remoteEntry valueForKey:@"objectId"]]) {
                        NSLog(@"Update: %@", objectId);
                        localEntry.updatedAt = remoteEntry.updatedAt;
                        localEntry.lookups = [remoteEntry objectForKey:@"lookups"];
                    }
                } else {
                    Entry *newLocalEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"       
                                                                         inManagedObjectContext:self.managedObjectContext];
                    newLocalEntry.createdAt = remoteEntry.createdAt;
                    newLocalEntry.updatedAt = remoteEntry.updatedAt;
                    newLocalEntry.objectId = remoteEntry.objectId;
                    
                    for (id key in [remoteEntry allKeys]) {
                        if (![key isEqualToString:@"user"]) {
                            NSObject *value = [remoteEntry objectForKey:key];
                            [newLocalEntry setValue:value forKey:key];
                        }
                    }
                }
                currentIndex ++;
            }

            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error in adding a new bank %@, %@", error, [error userInfo]);
                abort();
            } 
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict addEntriesFromDictionary:lastUpdatedAt];
            [dict setObject:[NSDate date] forKey:lang];
            [self.prefs setObject:dict forKey:@"lastUpdatedAt"];
            
            // Console meesage at this line:
            // "No memory available to program now: unsafe to call malloc"
            [self showLastUpdate];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)showLastUpdate
{
    NSString *lang = [self.prefs objectForKey:@"lang"];
    NSDictionary *lastUpdatedAt = [self.prefs dictionaryForKey:@"lastUpdatedAt"];
    NSDate *lastUpdateAtOfLang = [lastUpdatedAt objectForKey:lang];
    if (!([lastUpdateAtOfLang isEqualToDate:[NSDate distantPast]])) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:lastUpdateAtOfLang];
        NSString *text = @"Last updated: ";
        _lastUpdatedAt.text = [text stringByAppendingString:formattedDateString];
    }
}

- (void)viewDidUnload
{
    _lastUpdatedAt = nil;
    [super viewDidUnload];
    __fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SDSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SDSyncEngineSyncCompleted" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView 
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView 
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Entry *localEntry = (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [localEntry setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query getObjectInBackgroundWithId:localEntry.objectId
                                     block:^(PFObject *remoteEntry, NSError *error) {
                                         [remoteEntry setObject:[NSNumber numberWithBool:YES] forKey:@"hidden"];
                                         [remoteEntry saveInBackground];
                                     }];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Entry *entry = (Entry *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSArray* words = [entry.word componentsSeparatedByString:@","];
    [self.detailViewController showDetailOfWord:[words objectAtIndex:0] 
                                ofEntryObjectId:entry.objectId 
                                     ofLanguage:entry.lang]; 
}

/*
- (NSString*)formatWordsToMultipleLines:(NSIndexPath *)indexPath 
{
        
}
*/

// Don't do it. It's too expensive. It's called for each cell, even for those invisible.
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *multiLineWords = [[selectedObject valueForKey:@"word"] stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    
    CGSize size = [multiLineWords
                   sizeWithFont:[UIFont boldSystemFontOfSize:17] 
                   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    return size.height + 10;
}
 */


#pragma mark - Fetched results controller



- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry" 
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    // 'hidden' attribute was added late and many of them were nil (undefined on Parse.com also)
    // without hidden == nil, they won't be fetched.
    NSString *lang = [self.prefs objectForKey:@"lang"];
    NSPredicate *predicate = nil;
    if ([self.prefs boolForKey:@"hideKnownWords"]) {
        predicate = [NSPredicate predicateWithFormat:@"lang == %@ && (hidden == nil || hidden == NO)", lang];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"lang == %@", lang];
    }
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = nil;
    NSString *sectionNameKeyPath = nil;
    
    if ([self.prefs integerForKey:@"groupedBy"] == 0) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
        // See NSDate+RelativeExtension
        sectionNameKeyPath = @"updatedAt.relativeDate";
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lookups" ascending:NO];
        sectionNameKeyPath = @"lookups";
    } 
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
                                                             initWithFetchRequest:fetchRequest 
                                                             managedObjectContext:self.managedObjectContext 
                                                             sectionNameKeyPath:sectionNameKeyPath 
                                                             cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
    //[self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            /*[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath]; // new in iOS 5
             */
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Entry *entry = (Entry *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *words = entry.word;
    // arruffato,arruffare,affuffarsi -> arruffato,arruffare...
    if ([words length] > 27) {
        NSRange commaRange = [words rangeOfString:@"," options:NSBackwardsSearch];
        if (commaRange.location != NSNotFound) {
            words = [[words substringToIndex:commaRange.location] stringByAppendingString:@"..."];
        }
    }
    cell.textLabel.text = words;
    
    if (entry.hidden) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    //cell.textLabel.numberOfLines = 0;
    
    NSInteger lookups = [entry.lookups intValue];
    
    // This is only for debugging
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", lookups];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"config"]) {
        UINavigationController *navController = (UINavigationController *) segue.destinationViewController;
        ConfigViewController *controller = (ConfigViewController *) navController.topViewController;
        controller.delegate = self;
        controller.prefs = self.prefs;
        _prefsBeforeConfig = [self.prefs dictionaryRepresentation];
    }
}



- (void)configViewDidDone:(ConfigViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *lang = [self.prefs objectForKey:@"lang"];
    self.title = [_kLangFullNames valueForKey:lang];
    
    if (![_prefsBeforeConfig isEqualToDictionary:[self.prefs dictionaryRepresentation]]) {
        // FIXME: is there more elegante way to do this ?
        self.fetchedResultsController = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - SDTableViewDelegate

- (void)willReloadData {}

- (void)didReloadData 
{
    if ([PFUser currentUser]) [self syncWithWebService];
}

- (void)willLayoutSubviews {}
- (void)didLayoutSubviews {}

- (IBAction)reload:(id)sender {
    if ([PFUser currentUser]) [self syncWithWebService];
}
@end
