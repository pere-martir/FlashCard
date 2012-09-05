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
- (void)configView:(ConfigViewController *)controller didSelectLanguage:(NSString*)lang;

@end

@interface ConfigViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
    NSDictionary *_kLangFullNames;
    NSArray *_kLanguages;
    int _selectedLang;
}

@property (weak, nonatomic) id<ConfigViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *_langPicker;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
