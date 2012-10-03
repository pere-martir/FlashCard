//
//  FCDetailViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FCDetailViewController.h"
#import "NotesViewController.h"
#import "Entry.h"
#import "Note.h"

@interface FCDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation FCDetailViewController

@synthesize webView = _webView;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize prefs = _prefs;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize entryObjectId = _entryObjectId;

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
    _incrementLookupsAfterLoaded = FALSE;
    _currentWordHandled = FALSE;
    _currentTab = 0;
    _lang = [[self.prefs stringForKey:@"lang"] copy];
    _note.text = @"";
    _tabbar.selectedItem = [_tabbar.items objectAtIndex:_currentTab];
    
    // http://stackoverflow.com/questions/10996028/uiwebview-when-did-a-page-really-finish-loading
    // http://winxblog.com/2009/02/iphone-uiwebview-estimated-progress/
        
    self.webView.delegate = self;
    _searchBar.delegate = self;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    _tabbar = nil;
    _wordToBeSearched = nil;
    _word = nil;
    _tabBarItemWR = nil;
    _toolbar = nil;
    _note = nil;
    _showMoreNotes = nil;
    _searchBar = nil;
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutDetailView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Words", @"Words");
    NSMutableArray *items = [[_toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [_toolbar setItems:items animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[_toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [_toolbar setItems:items animated:YES];
    self.masterPopoverController = nil;
}

- (void)showEntry:(Entry*)entry 
{
    // firstWord is used to create the URL of the page of WordReference
    NSString* firstWord = [[entry.word componentsSeparatedByString:@","] objectAtIndex:0];
    self.entryObjectId = entry.objectId;
    [self showDetailOfWord:firstWord ofLanguage:entry.lang andIncrementLookups:YES];
    
    NSSet *notes = entry.notes;
    NSDate *latestUpdatedAt = nil;
    NSArray *sortedNotes = nil;
    if ([notes count] > 0) {
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
        sortedNotes = [notes sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        Note *note = (Note *)[sortedNotes objectAtIndex:0];
        latestUpdatedAt = note.updatedAt;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Note"];
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"entryObjectId" equalTo:entry.objectId];
    if (latestUpdatedAt) [query whereKey:@"updatedAt" greaterThan:latestUpdatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *remoteNotes, NSError *error) {
        NSMutableArray *allNotes = [NSMutableArray arrayWithArray:sortedNotes];
        for (PFObject *remoteNote in remoteNotes) {
            Note *newLocalNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"       
                                                                       inManagedObjectContext:self.managedObjectContext];
            newLocalNote.entry = entry;
            newLocalNote.objectId = remoteNote.objectId;
            newLocalNote.createdAt = remoteNote.createdAt;
            newLocalNote.updatedAt = remoteNote.updatedAt;
            newLocalNote.entryObjectId = [remoteNote objectForKey:@"entryObjectId"];
            newLocalNote.note = [remoteNote objectForKey:@"note"];
            if ([[remoteNote allKeys] containsObject:@"word"]) 
                newLocalNote.word = [remoteNote objectForKey:@"word"];
            if ([[remoteNote allKeys] containsObject:@"title"]) 
                newLocalNote.title = [remoteNote objectForKey:@"title"];
            if ([[remoteNote allKeys] containsObject:@"url"]) 
                newLocalNote.url = [remoteNote objectForKey:@"url"];
            [allNotes insertObject:newLocalNote atIndex:0];
        }
        
        error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to save to Core Data (objectId)");
            abort();
        } else {
            // TODO:perhaps [self appendNotes] is better ?
            // Or even beter, monitoring the changes of Core Data -> Observer
            [self showNotes: allNotes]; 
        }
    }];    
}

- (void)showNotes:(NSArray*)notes
{
    NSMutableArray *notesArray = [[NSMutableArray alloc]init];
    for (Note *note in notes) {
        // Add bracket parenthesis to the matched substring in the sentence
        NSString *n = note.note;
        if (note.word) {
            NSString *substirngWithBrackets = [NSString stringWithFormat:@"[%@]", note.word];
            NSString *highlightedNote = [n stringByReplacingOccurrencesOfString:note.word 
                                                                     withString:substirngWithBrackets];
            [notesArray addObject:highlightedNote];
        } else {
            [notesArray addObject:n];
        }
    }
    
    if ([notesArray count] == 0)
        _note.text = @"";
    else
        _note.text = [notesArray componentsJoinedByString:@" / "];
    
    [self layoutDetailView];
}

- (void)layoutDetailView
{
    if ([_note.text length] == 0) {
        _note.hidden = YES;
        _showMoreNotes.hidden = YES;
        _webView.frame = CGRectMake(_webView.frame.origin.x, _webView.frame.origin.y, 
                                    _webView.frame.size.width, 
                                    CGRectGetMinY(_tabbar.frame) - CGRectGetMinY(_webView.frame));
    } else {
        const CGFloat MARGIN = 5;
        _note.hidden = NO;
        const CGRect MAX_FRAME = CGRectMake(0, 0, 
                                            CGRectGetWidth(_tabbar.frame) - CGRectGetWidth(_showMoreNotes.frame) - MARGIN * 3, 
                                            93);
        _note.frame = CGRectMake(0, 0, CGRectGetWidth(MAX_FRAME), 0);
        [_note sizeToFit];
        if (CGRectGetHeight(_note.frame) > CGRectGetHeight(MAX_FRAME)) _note.frame = MAX_FRAME;
        
        // Align the bottom of the label to the top of the tabbar
        _note.frame = CGRectMake(_tabbar.frame.origin.x + MARGIN, 
                                 _tabbar.frame.origin.y - MARGIN - CGRectGetHeight(_note.frame) - MARGIN,
                                 CGRectGetWidth(_note.frame), CGRectGetHeight(_note.frame));
        
        _showMoreNotes.frame = CGRectMake(CGRectGetMaxX(_tabbar.frame) - MARGIN - CGRectGetWidth(_showMoreNotes.frame),
                                          CGRectGetMidY(_note.frame) - CGRectGetWidth(_showMoreNotes.frame) / 2,
                                          CGRectGetWidth(_showMoreNotes.frame), CGRectGetHeight(_showMoreNotes.frame));
        _showMoreNotes.hidden = NO;
        
        _webView.frame = CGRectMake(_webView.frame.origin.x, _webView.frame.origin.y, 
                                    _webView.frame.size.width, 
                                    CGRectGetMinY(_note.frame) - CGRectGetMinY(_webView.frame) - MARGIN);
    }
}

- (void)showDetailOfWord:(NSString*)word ofLanguage:(NSString*)lang 
     andIncrementLookups:(BOOL)incrementLookup
{
    _word = [word copy];
    _lang = [lang copy];
    
    if (0 == _currentTab) {
        [self showEnglishTranslation:incrementLookup];
    } else if (1 == _currentTab) {
        [self showDefinition];
    } else if (2 == _currentTab) {
        [self showWikipedia];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    _currentTab = 0;
    _tabbar.selectedItem = _tabBarItemWR;
    _word = [searchBar.text copy];
    [self showEnglishTranslation:YES];
}

- (void)showEnglishTranslation:(BOOL)incrementLookup
{
    NSString *url = nil;
    if ([_lang isEqualToString:@"es"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/es/en/translation.asp?spen=%@", _word];
    else if ([_lang isEqualToString:@"it"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/iten/%@", _word];
        
    if (url) {
        _currentWordHandled = NO;
        _incrementLookupsAfterLoaded = incrementLookup;
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
    
    if (_currentTab == 0) {
        // scroll the view so that the advertisement and the word list on the left hand side are not visible.
        // window.scrollBy(70, 80);
        [webView stringByEvaluatingJavaScriptFromString:@"document. body.style.zoom = 1.4;"];
    }
    
    if (_incrementLookupsAfterLoaded) {
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
}

- (void)incrementLookupOf:(NSString*)word
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Entry" 
                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSString *comma = @",";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(word LIKE[c] %@ OR word BEGINSWITH[c] %@ OR \
                                 word ENDSWITH[c] %@ OR word CONTAINS[c] %@) AND lang==%@", 
                              word, 
                              [word stringByAppendingString:@","], 
                              [comma stringByAppendingString:word],
                              [[comma stringByAppendingString:word] stringByAppendingString:comma], _lang];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert([result count] <= 1, @"more than one entry found of the same word");
    Entry *entry = nil;
    BOOL addNewWord = FALSE;
    if ([result count] == 0) addNewWord = TRUE;
    if (addNewWord) {
        entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry"       
                                              inManagedObjectContext:self.managedObjectContext];
        entry.objectId = @"";
        entry.createdAt = [NSDate date];
        entry.lookups = [NSNumber numberWithInt:1];
        entry.word = word;
        entry.lang = _lang;
    } else {
        NSAssert([result count] == 1, @"more than on result");
        entry = (Entry *)[result lastObject];
        int lookups = [[entry valueForKey:@"lookups"] intValue] + 1;
        entry.lookups = [NSNumber numberWithInt:lookups];
    }
    entry.updatedAt = [NSDate date];
    
    if (addNewWord) {
        PFObject *remoteEntry = [PFObject objectWithClassName:@"Entry"];
        [remoteEntry setObject:[PFUser currentUser] forKey:@"user"];
        [remoteEntry setObject:_lang forKey:@"lang"];
        [remoteEntry setObject:word forKey:@"word"];
        [remoteEntry setObject:[NSNumber numberWithInt:1] forKey:@"lookups"];
        [remoteEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
            //[entry setValue:remoteEntry.objectId forKey:@"objectId"];
            entry.objectId = remoteEntry.objectId;
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
        
        error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Failed to update Entry");
            abort();
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Entry"];
        [query getObjectInBackgroundWithId:entry.objectId //[entry valueForKey:@"objectId"] 
                         block:^(PFObject *remoteEntry, NSError *error) {
                             NSNumber *lookups = entry.lookups; //[entry valueForKey:@"lookups"];
                             if (!error) {
                                 [remoteEntry setObject:lookups forKey:@"lookups"];
                                 [remoteEntry saveInBackground];
                             } else {
                                 // make it 'dirty' so that it will be synchronized
                                 // when the network connection is available.
                                 NSLog(@"Failed to sync to remote");
                                 abort();
                             }
                         }];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowNotes"]) {
        NotesViewController *controller = (NotesViewController *) segue.destinationViewController;
        //controller.delegate = self;
        controller.managedObjectContext = self.managedObjectContext;
        assert(self.entryObjectId != nil);
        controller.entryObjectId = self.entryObjectId;
    }
}



#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger tag = item.tag;
    if (_currentTab != tag) {
        _currentTab = tag;
        [self showDetailOfWord:_word ofLanguage:_lang andIncrementLookups:NO];
    }
}

@end
