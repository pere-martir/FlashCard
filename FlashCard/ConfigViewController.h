//
//  ConfigViewController.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConfigViewController;

@protocol ConfigViewControllerDelegate <NSObject>

- (void)configViewDidCancel:(ConfigViewController *)controller;
- (void)configView:(ConfigViewController *)controller 
 didSelectLanguage:(NSString*)lang
      andGroupedBy:(NSInteger)groupedBy;
@end

@interface ConfigViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    NSDictionary *_kLangFullNames;
    NSArray *_kLanguages;
    int _selectedLang;
    __weak IBOutlet UISegmentedControl *_groupedBy;
}

@property (weak, nonatomic) NSUserDefaults *prefs;
@property (weak, nonatomic) id<ConfigViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *_langPicker;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)changeGroupedBy:(id)sender;

@end
