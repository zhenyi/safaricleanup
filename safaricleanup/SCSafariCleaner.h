//
//  SCSafariCleaner.h
//  safaricleanup
//
//  Created by Zhenyi Tan on 31/10/13.
//  Copyright (c) 2013 And a Dinosaur. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCMatchingOption) {
    SCMatchingAny = 1,
    SCMatchingNone
};

@interface SCSafariCleaner : NSObject

+ (int) run;

@end
