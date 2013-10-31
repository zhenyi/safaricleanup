//
//  main.m
//  safaricleanup
//
//  Created by Zhenyi Tan on 31/10/13.
//  Copyright (c) 2013 And a Dinosaur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSafariCleaner.h"


int main (int argc, const char * argv[]) {

    int exitStatus;

    @autoreleasepool {
        exitStatus = [SCSafariCleaner run];
    }

    return exitStatus;
}