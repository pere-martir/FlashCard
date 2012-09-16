//
//  LanguageViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LanguageViewController.h"


@implementation LanguageViewController

//@synthesize currLang = _currLang;
@synthesize delegate = _delegate, langNames = _langNames, prefs = _prefs;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *lang = [self.prefs objectForKey:@"lang"];
    _langNamesArray = [self.langNames allValues];
    _langCodesArray = [self.langNames allKeys];
    for (int i = 0; i < [_langCodesArray count]; ++i) {
        NSString* code = (NSString *)[_langCodesArray objectAtIndex:i];
        if ([code isEqualToString:lang]) {
            _lastSelectedRow = i;
            break;
        }
    }
}

- (void)viewDidUnload
{
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_langNamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_langNamesArray objectAtIndex:indexPath.row];
    if (indexPath.row == _lastSelectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_lastSelectedRow == indexPath.row) return;
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;  // show checkmark
    [cell setSelected:NO animated:YES];                      // deselect row so it doesn't remain selected
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastSelectedRow inSection:0]];     
    cell.accessoryType = UITableViewCellAccessoryNone;       // remove check from previously selected row
    _lastSelectedRow = indexPath.row;                             // remember the newly selected row
    [self.prefs setObject:[_langCodesArray objectAtIndex:indexPath.row] forKey:@"lang"];
}

@end
