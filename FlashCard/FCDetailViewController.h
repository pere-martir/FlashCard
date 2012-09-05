//
//  FCDetailViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCDetailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate, UITabBarDelegate> {
    int _currentTab;
    NSString* _word;
    NSString* _lang;
    __weak IBOutlet UITabBar *_tabbar;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UILabel *DefinitionView;

- (void)showEnglishTranslation;
- (void)showDefinition;

- (void)showDetailOfWord:(NSString*)word ofLanguage:(NSString*)lang;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;

@end
