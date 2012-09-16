//
//  FCMasterViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCDetailViewController;

#import <CoreData/CoreData.h>

#import "ConfigViewController.h"

@interface FCMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                           ConfigViewControllerDelegate> 
{
    NSDictionary *_kLangFullNames;
    NSDictionary *_prefsBeforeConfig;
    __weak IBOutlet UILabel *_lastUpdatedAt;
}

@property (weak, nonatomic) NSUserDefaults *prefs;
@property (strong, nonatomic) FCDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)syncWithWebService;
- (void)showLastUpdate;

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView 
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath;

-(NSString *)tableView:(UITableView *)tableView 
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
