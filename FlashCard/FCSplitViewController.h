//
//  FCSplitViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginViewController.h"

@interface FCSplitViewController : UISplitViewController<LoginViewDelegate>

- (void)viewDidAppear:(BOOL)animated;

@end
