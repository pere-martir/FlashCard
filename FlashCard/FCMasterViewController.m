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


@interface FCMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FCMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize lang = _lang;
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
    
    _groupedBy = [self.prefs integerForKey:@"groupedBy"];
    NSString* lang = [self.prefs stringForKey:@"lang"];
    if (nil == lang) lang = @"es";
    self.lang = lang;
    
    if ([PFUser currentUser]) [self syncWithWebService];
    
    NSError* error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


- (void) setLang:(NSString *)lang
{
    if (![self.lang isEqualToString:lang]) {
        _lang = lang;
        [self.prefs setObject:_lang forKey:@"lang"];
        self.fetchedResultsController = nil;
        self.title = [_kLangFullNames valueForKey:lang];
        [self.tableView reloadData];
    }
}


- (void) syncWithWebService
{
    NSAssert([PFUser currentUser], @"No logined user");
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //NSString* lang = [defaults stringForKey:@"lang"];
    //if (lang == nil) lang = @"es";
    NSDate* lastUpdatedAt = [defaults objectForKey:@"lastUpdatedAt"];
    if (lastUpdatedAt == nil) lastUpdatedAt = [NSDate distantPast];

    PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
    [query whereKey:@"updatedAt" greaterThan:lastUpdatedAt];
    //[query whereKey:@"lang" equalTo:self.lang];
    // Use "paged-index" to fetch all - 
    //  http://engineering.linkedin.com/voldemort/voldemort-collections-iterating-over-key-value-store
    query.limit = 1000; // TODO: ???
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
                NSManagedObject *localEntry = nil;
                if ([localEntries count] > currentIndex) {
                    localEntry = [localEntries objectAtIndex:currentIndex];
                    
                    NSString * objectId = [localEntry valueForKey:@"objectId"];
                    if ([objectId isEqualToString: [remoteEntry valueForKey:@"objectId"]]) {
                        NSLog(@"Update: %@", objectId);
                        [localEntry setValue:remoteEntry.updatedAt forKey:@"updatedAt"];
                        [localEntry setValue:[remoteEntry objectForKey:@"lookups"] forKey:@"lookups"];
                    }
                } else {
                    NSManagedObject *newLocalEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"       
                                                                              inManagedObjectContext:self.managedObjectContext];

                    [newLocalEntry setValue:remoteEntry.createdAt forKey:@"createdAt"];
                    [newLocalEntry setValue:remoteEntry.updatedAt forKey:@"updatedAt"];
                    [newLocalEntry setValue:remoteEntry.objectId  forKey:@"objectId"];
                    
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
            
            [self.prefs setObject:[NSDate date] forKey:@"lastUpdatedAt"];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewDidUnload
{
    //_langButton = nil;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
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
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [self.detailViewController showDetailOfWord:[selectedObject valueForKey:@"word"]
                                     ofLanguage:[selectedObject valueForKey:@"lang"]
                                                        andIncrementLookups:YES];
}

#pragma mark - Fetched results controller



- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lang == %@", self.lang];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = nil;
    NSString *sectionNameKeyPath = nil;
    if (_groupedBy == 0) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
        sectionNameKeyPath = @"updatedAt.relativeDate";
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lookups" ascending:NO];
        sectionNameKeyPath = @"lookups";
    } 
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
                                                             initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
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
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"word"];
    
    NSInteger lookups = [[managedObject valueForKey:@"lookups"] intValue];
    
    // This is only for debugging
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", lookups];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"config"]) {
        ConfigViewController *controller = (ConfigViewController *) segue.destinationViewController;
        controller.delegate = self;
        controller.prefs = self.prefs;
    }
}

- (void)configViewDidCancel:(ConfigViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configView:(ConfigViewController *)controller didSelectLanguage:(NSString*)lang
      andGroupedBy:(NSInteger)groupedBy;
{
    [self.navigationController popViewControllerAnimated:YES];
    if (![_lang isEqualToString:lang] || _groupedBy != groupedBy) {
        _lang = lang;
        _groupedBy = groupedBy;
        [self.prefs setObject:_lang forKey:@"lang"];
        [self.prefs setInteger:_groupedBy forKey:@"groupedBy"];
        self.fetchedResultsController = nil;
        self.title = [_kLangFullNames valueForKey:lang];
        [self.tableView reloadData];
    }
}



@end
