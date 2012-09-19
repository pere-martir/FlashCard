//
//  Entry.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Entry : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * lookups;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;
@end
