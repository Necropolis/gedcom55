//
//  FSGEDCOMStructure.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMStructure.h"

#import "FSByteScanner.h"

@implementation FSGEDCOMStructure

+ (NSMutableArray*)registeredSubclasses
{
    static NSMutableArray* registeredSubclasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredSubclasses = [[NSMutableArray alloc] init];
    });
    return registeredSubclasses;
}

+ (void)load
{
    @autoreleasepool {
        Class c0=[self class];
        if (c0!=[FSGEDCOMStructure class]) { // only respond to subclasses
            [[self registeredSubclasses] addObject:c0];
        }
    }
}

+ (struct byte_sequence)respondsTo
{
    [NSException raise:@"Pure Virtual Called" format:@"%s is supposed to be pure-virtual", __PRETTY_FUNCTION__];
    struct byte_sequence s;
    return s;
}

- (struct byte_sequence)respondsTo
{
    return [[self class] respondsTo];
}

- (NSDictionary*)parseStructure:(struct byte_buffer*)buff
{
    [NSException raise:@"Pure Virtual Called" format:@"%s is supposed to be pure-virtual", __PRETTY_FUNCTION__];
    return nil;
}

@end
