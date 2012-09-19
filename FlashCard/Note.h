//
//  Note.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entry;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * entryObjectId;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) Entry *entry;

@end
