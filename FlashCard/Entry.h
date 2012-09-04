//
//  Entry.h
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entry : NSManagedObject

@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * lookups;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;

@end
