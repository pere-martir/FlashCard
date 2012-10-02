//
//  FCDetailViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entry;

@interface FCDetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UITabBarDelegate,
                                                      UISearchBarDelegate> {
    int _currentTab;
    NSString* _entryObjectId;
    NSString* _word;
    NSString* _lang;
    BOOL _currentWordHandled;
    BOOL _incrementLookupsAfterLoaded;
    __weak IBOutlet UITabBarItem *_tabBarItemWR;
    __weak IBOutlet UITabBar *_tabbar;
    __weak IBOutlet UITextField *_wordToBeSearched;
    __weak IBOutlet UIToolbar *_toolbar;
    __weak IBOutlet UILabel *_note;
    __weak IBOutlet UIButton *_showMoreNotes;
    __weak IBOutlet UISearchBar *_searchBar;
}

@property (weak, nonatomic) NSUserDefaults* prefs;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//- (IBAction)search:(id)sender;
//- (IBAction)didEndOnExit:(id)sender;

- (void)showEnglishTranslation:(BOOL)incrementLookup;
- (void)showDefinition;
- (void)showWikipedia;

- (void)showEntry:(Entry*)entry;
- (void)showNotes:(NSArray*)notes;

- (void)showDetailOfWord:(NSString*)word ofLanguage:(NSString*)lang 
  andIncrementLookups:(BOOL)lookupsIncremented;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;

- (void)incrementLookupOf:(NSString*)word;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
