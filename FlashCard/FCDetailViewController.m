//
//  FCDetailViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FCDetailViewController.h"

@interface FCDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation FCDetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize webView = _webView;
@synthesize DefinitionView = _DefinitionView;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
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
    _currentTab = 0;
    self.webView.delegate = self;
    _tabbar.selectedItem = [_tabbar.items objectAtIndex:_currentTab];
    [self configureView];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setDefinitionView:nil];
    _tabbar = nil;
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
    }
}

- (void)showEnglishTranslation
{
    NSString *url = nil;
    if ([_lang isEqualToString:@"es"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/es/en/translation.asp?spen=%@", _word];
    else if ([_lang isEqualToString:@"it"])
        url = [NSString stringWithFormat:@"http://www.wordreference.com/iten/%@", _word];
        
    if (url) {
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

@end
