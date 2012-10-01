//
//  NoteCell.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCell : UITableViewCell
{
}

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* sentenceLabel;

@end
