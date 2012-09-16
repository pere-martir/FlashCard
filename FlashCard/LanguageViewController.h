//
//  LanguageViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LanguageViewController;

@protocol LanguageViewControllerDelegete <NSObject>
- (void)languageView:(LanguageViewController*)controller didDoneWithLanguage:(NSString*)lang;
@end

@interface LanguageViewController : UITableViewController
{
    NSArray *_langNamesArray;
    NSArray *_langCodesArray;
    NSUInteger _lastSelectedRow;
}

//@property (weak, nonatomic) NSString *currLang;
@property (weak, nonatomic) NSUserDefaults *prefs;
@property (weak, nonatomic) NSDictionary *langNames;
@property (weak, nonatomic) id<LanguageViewControllerDelegete> delegate;

@end
