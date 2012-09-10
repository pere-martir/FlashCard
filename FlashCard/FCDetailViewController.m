//
//  FCDetailViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FCDetailViewController.h"
#import "WebView.h"
#import "UIWebDocumentView.h"

@interface FCDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation FCDetailViewController

@synthesize webView = _webView;

@synthesize masterPopoverController = _masterPopoverController;
@synthesize prefs = _prefs;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Managing the detail item

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentTab = 0;
    _lang = [[self.prefs stringForKey:@"lang"] copy];

    _tabbar.selectedItem = [_tabbar.items objectAtIndex:_currentTab];
    
    // http://stackoverflow.com/questions/10996028/uiwebview-when-did-a-page-really-finish-loading
    // http://winxblog.com/2009/02/iphone-uiwebview-estimated-progress/
    UIWebDocumentView *documentView = [self.webView _documentView];
    // This is private of WebKit
    WebView *coreWebView = [documentView webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(progressFinished:) 
                                                 name:@"WebProgressFinishedNotification" 
                                               object:coreWebView];    
    
    self.webView.delegate = self;
}

- (void)viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"WebProgressFinishedNotification" 
                                                  object:nil];
    
    [self setWebView:nil];
    _tabbar = nil;
    _wordToBeSearched = nil;
    _word = nil;
    _tabBarItemWR = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Words", @"Words");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)showDetailOfWord:(NSString*)word ofLanguage:(NSString*)lang
{
    _word = [word copy];
    _lang = [lang copy];
    if (0 == _currentTab) {
        [self showEnglishTranslation];
    } else if (1 == _currentTab) {
        [self showDefinition];
    } else if (2 == _currentTab) {
        [self showWikipedia];
    }
}

// REFACTORING: merge these two functions
- (IBAction)search:(id)sender {
    _currentTab = 0;
    _tabbar.selectedItem = _tabBarItemWR;
    _word = [_wordToBeSearched.text copy];
    [self showEnglishTranslation];
}

- (IBAction)didEndOnExit:(id)sender {
    [sender resignFirstResponder];
    _currentTab = 0;
    _tabbar.selectedItem = _tabBarItemWR;
    _word = [_wordToBeSearched.text copy];
    [self showEnglishTranslation];
}

- (void)showEnglishTranslation
{
    NSString *url = nil;
    if ([_lang isEqualToString:@"es"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/es/en/translation.asp?spen=%@", _word];
    else if ([_lang isEqualToString:@"it"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/iten/%@", _word];
        
    if (url) {
        _currentWordHandled = NO;
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:req];
    }
}

- (void)showDefinition
{
    NSString *url = nil;
    if ([_lang isEqualToString:@"es"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/definicion/%@", _word];
    else if ([_lang isEqualToString:@"it"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/definizione/%@", _word];
    
    if (url) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:req];
    }
}

- (void)showWikipedia
{
    NSString *url = [NSString stringWithFormat:@"http://%@.wikipedia.org/wiki/%@", _lang, _word];
    if (url) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:req];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
#if 0 // it doesn't work
    if ([webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[webView scrollView];
        float zoom = webView.bounds.size.width / scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
#endif

    NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    
    NSRange range;
    if ([_lang isEqualToString:@"it"]) 
        range = [html rangeOfString:@"Concise Oxford Paravia Italian Dictionary"];
    else if ([_lang isEqualToString:@"es"])
        range = [html rangeOfString:@"Concise Oxford Spanish Dictionary"];
    
    // webViewDidFinishLoad will be called several times for a web page and
    // we cannot know which is the last one. In order not to add a word more 
    // than once, use _currentWordHandled. 
    if (range.location != NSNotFound) {
        if (!_currentWordHandled) {
            [self incrementLookupOf:_word];
            _currentWordHandled = TRUE;
        }
    }
}

- (void)incrementLookupOf:(NSString*)word
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Entry" 
                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word==%@ AND lang==%@", word, _lang];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert([result count] <= 1, @"more than one entry found of the same word");
    NSManagedObject *entry = nil;
    BOOL addNewWord = FALSE;
    if ([result count] == 0) addNewWord = TRUE;
    if (addNewWord) {
        entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"       
                                              inManagedObjectContext:self.managedObjectContext];
        [entry setValue:@"" forKey:@"objectId"]; // ???
        [entry setValue:[NSDate date] forKey:@"createdAt"];
        [entry setValue:[NSNumber numberWithInt:1] forKey:@"lookups"];
        [entry setValue:word forKey:@"word"];
        [entry setValue:_lang forKey:@"lang"];
    } else {
        entry = [result lastObject];
        int lookups = [[entry valueForKey:@"lookups"] intValue] + 1;
        [entry setValue:[NSNumber numberWithInt:lookups] forKey:@"lookups"];
    }
    [entry setValue:[NSDate date] forKey:@"updatedAt"];
    
    error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Failed to update Entry");
        abort();
    } 
    
    if (addNewWord) {
        PFObject *remoteEntry = [PFObject objectWithClassName:@"Entry"];
        [remoteEntry setObject:[PFUser currentUser] forKey:@"user"];
        [remoteEntry setObject:_lang forKey:@"lang"];
        [remoteEntry setObject:word forKey:@"word"];
        [remoteEntry setObject:[NSNumber numberWithInt:1] forKey:@"lookups"];
        [remoteEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
            [entry setValue:remoteEntry.objectId forKey:@"objectId"];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save to Core Data (objectId)");
                    abort();
                } else {
                    // Do thing since we can later find all object with empty 
                    // objectId and sync them back to Parse.com
                }
            });
        }];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query getObjectInBackgroundWithId:[entry valueForKey:@"objectId"] 
                         block:^(PFObject *remoteEntry, NSError *error) {
                             NSNumber *lookups = [entry valueForKey:@"lookups"];
                             if (!error) {
                                 [remoteEntry setObject:lookups forKey:@"lookups"];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     NSError *error;
                                     if (![self.managedObjectContext save:&error]) {
                                         NSLog(@"Failed to update lookups");
                                         abort();
                                     }
                                 });
                             } else {
                                 // make it 'dirty' so that it will be synchronized
                                 // when the network connection is available.
                                 NSLog(@"Failed to sync to remote");
                                 abort();
                             }
                         }];
    }
    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    if (_currentTab != tag) {
        _currentTab = tag;
        [self showDetailOfWord:_word ofLanguage:_lang];
    }
}

#pragma mark - WebViewProgressEstimateChangedNotification 

- (void)progressFinished:(NSNotification*)theNotification {

//    int progress = (int)[[theNotification object] estimatedProgress];

//    NSLog(@"progressEstimateChanged: %d", progress);
    NSLog(@"progressFinished ***");
	
    
}

@end
