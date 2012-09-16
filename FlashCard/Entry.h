//
//  Entry.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entry : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * lookups;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * word;

@end
