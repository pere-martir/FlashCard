//
//  DefaultSettingsViewController.h
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

//#import "PFLoginViewControllerDelegate.h"

@protocol LoginViewDelegate
- (void) didLoginUser;
@end


@interface DefaultSettingsViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    //id<LoginViewDelegate> delegate;
}

@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

@property (nonatomic, assign) id<LoginViewDelegate> delegate;
- (IBAction)logOutButtonTapAction:(id)sender;

@end
