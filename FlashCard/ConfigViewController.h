//
//  ConfigViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageViewController.h"

@class ConfigViewController;

@protocol ConfigViewControllerDelegate <NSObject>

- (void)configViewDidDone:(ConfigViewController*)controller;
/*
- (void)configViewDidCancel:(ConfigViewController*)controller;
- (void)configView:(ConfigViewController *)controller 
 didSelectLanguage:(NSString*)lang
      andGroupedBy:(NSInteger)groupedBy;
 */
@end


@interface ConfigViewController : UITableViewController<LanguageViewControllerDelegete>
{
    NSDictionary *_kLangFullNames;
}


@property (weak, nonatomic) IBOutlet UILabel *lang;
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupedBy;
@property (weak, nonatomic) IBOutlet UISwitch *hideKnownWords;

@property (weak, nonatomic) NSUserDefaults *prefs;
@property (weak, nonatomic) id<ConfigViewControllerDelegate> delegate;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (IBAction)done:(id)sender;

- (void)languageView:(LanguageViewController*)controller didDoneWithLanguage:(NSString*)lang;

@end
