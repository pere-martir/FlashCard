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

@interface FCMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSDictionary *_kLangFullNames;
    __weak IBOutlet UIBarButtonItem *_langButton;
}

@property (strong, nonatomic) FCDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (copy, nonatomic, setter=setLang:) NSString* lang;

- (void)syncWithWebService;
- (void)loadEntriesFromCoreData;
- (IBAction)changeLanguage:(id)sender;


@end
