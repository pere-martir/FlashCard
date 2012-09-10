//
//  FCDetailViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCDetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UITabBarDelegate> {
    int _currentTab;
    NSString* _word;
    NSString* _lang;
    BOOL _currentWordHandled;
    __weak IBOutlet UITabBarItem *_tabBarItemWR;
    __weak IBOutlet UITabBar *_tabbar;
    __weak IBOutlet UITextField *_wordToBeSearched;
}

@property (weak, nonatomic) NSUserDefaults* prefs;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)search:(id)sender;
- (IBAction)didEndOnExit:(id)sender;

- (void)showEnglishTranslation;
- (void)showDefinition;
- (void)showWikipedia;

- (void)showDetailOfWord:(NSString*)word ofLanguage:(NSString*)lang;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;

- (void)progressFinished:(NSNotification*)theNotification;
- (void)incrementLookupOf:(NSString*)word;
@end
