//
//  SDTableView.c
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDTableView.h"

@implementation SDTableView

/* Since this is a subclass of UITableView which already has a delegate property pointing to 
 MyTableViewController there's no need to add another one. The "@dynamic delegate" tells the 
 compiler to use this property. (Here's a link describing this: 
 http://farhadnoorzay.com/2012/01/20/objective-c-how-to-add-delegate-methods-in-a-subclass/)
 */
@dynamic delegate;

- (void) reloadData {
    [self.delegate willReloadData];
    
    [super reloadData];
    
    [self.delegate didReloadData];
}

- (void) layoutSubviews {
    [self.delegate willLayoutSubviews];
    
    [super layoutSubviews];
    
    [self.delegate didLayoutSubviews];
}

@end