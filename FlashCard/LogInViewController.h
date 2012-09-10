//
//  LoginViewController.h
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@protocol LoginViewDelegate
- (void) didLoginUser;
@end


@interface LoginViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {

}

@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

@property (nonatomic, assign) id<LoginViewDelegate> delegate;
- (IBAction)logOutButtonTapAction:(id)sender;

@end
