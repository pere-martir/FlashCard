//
//  FCSplitViewController.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FCSplitViewController.h"
#import "LoginViewController.h"
#import "FCMasterViewController.h"

@implementation FCSplitViewController

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    //[PFUser logOut];
    if (![PFUser currentUser]) { // No user logged in
        LoginViewController* loginVC = [[LoginViewController alloc] init];
        //loginVC.modalPresentationStyle = UIModalPresentationFormSheet;
        loginVC.delegate = self;
        //[self presentModalViewController:loginVC animated:TRUE];
        [self presentViewController:loginVC animated:TRUE completion:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didLoginUser
{
    [self dismissViewControllerAnimated:TRUE completion:nil];

    UINavigationController *masterNavigationController = [self.viewControllers objectAtIndex:0];
    FCMasterViewController *controller = (FCMasterViewController *)masterNavigationController.topViewController;
    
    [controller syncWithWebService];
}

@end
