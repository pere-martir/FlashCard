//
//  ConfigViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"

@implementation ConfigViewController
@synthesize lang = _lang;
@synthesize groupedBy = _groupedBy;
@synthesize hideKnownWords = _hideKnownWords;
@synthesize delegate = _delegate, prefs = _prefs;

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
}

- (void)viewDidUnload
{
    [self setLang:nil];
    [self setHideKnownWords:nil];
    [self setGroupedBy:nil];
    [self setHideKnownWords:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // REFACTOR ME
    // There should only be the languages available in Core Data
    if (!_kLangFullNames) {
        _kLangFullNames = [NSDictionary dictionaryWithObjectsAndKeys: 
                           @"Castellano", @"es",
                           @"Italiano", @"it", nil];
    }
    NSString* lang = [self.prefs stringForKey:@"lang"];
    self.lang.text = [_kLangFullNames objectForKey:lang];
    
    NSInteger x = [self.prefs integerForKey:@"groupedBy"];
    self.groupedBy.selectedSegmentIndex = x; 
    
    self.hideKnownWords.on = [self.prefs boolForKey:@"hideKnownWords"];
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
    return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"select_languages"]) {
        LanguageViewController *controller = (LanguageViewController *) segue.destinationViewController;
        controller.delegate = self;
        controller.langNames = _kLangFullNames;
        //controller.currLang = [self.prefs objectForKey:@"lang"];
        controller.prefs = self.prefs;
    }
}


- (IBAction)done:(id)sender {
    [self.prefs setObject:[NSNumber numberWithInt:self.groupedBy.selectedSegmentIndex] forKey:@"groupedBy"];
    [self.prefs setObject:[NSNumber numberWithBool:self.hideKnownWords.on] forKey:@"hideKnownWords"];
    [self.delegate configViewDidDone:self];
}


- (void)languageView:(LanguageViewController*)controller didDoneWithLanguage:(NSString*)lang
{
    [self.navigationController popViewControllerAnimated:TRUE];
    [self.prefs setObject:lang forKey:@"lang"];
    self.lang.text = [_kLangFullNames objectForKey:lang];
    
}

@end
