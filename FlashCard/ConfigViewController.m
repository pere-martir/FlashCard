//
//  ConfigViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"

@implementation ConfigViewController

@synthesize _langPicker, delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // REFACTOR ME
    // There should only be the languages available in Core Data
    if (!_kLangFullNames) {
        _kLangFullNames = [NSDictionary dictionaryWithObjectsAndKeys: 
                           @"Castellano", @"es",
                           @"Italiano", @"it", nil];
    }
    
    _kLanguages = [_kLangFullNames allValues];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* lang = [defaults stringForKey:@"lang"];
    if (nil == lang) lang = [[_kLangFullNames allKeys] objectAtIndex:0];
    
    NSString* langFullName = [_kLangFullNames objectForKey:lang];
    int index = [_kLanguages indexOfObject:langFullName];
    [_langPicker selectRow:index inComponent:0 animated:YES];
}


- (void)viewDidUnload
{
    [self set_langPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
            
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return  [_kLanguages count];
}
            
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    
    return [_kLanguages objectAtIndex:row];
} 
            
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row 
            inComponent:(NSInteger)component
{
    _selectedLang = row;
}

- (IBAction)done:(id)sender {
    [self.delegate configView:self didSelectLanguage:
     [[_kLangFullNames allKeys] objectAtIndex:_selectedLang]];
}

- (IBAction)cancel:(id)sender {
    [self.delegate configViewDidCancel:self];
}

@end
