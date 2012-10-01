//
//  NotesViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesViewController : UITableViewController<NSFetchedResultsControllerDelegate>
{
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *entryObjectId; // show the notes of this entry

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
