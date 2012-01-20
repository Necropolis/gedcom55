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

+ (struct byte_sequence)respondsTo
{
    return NULL; // pretend I'm virtual, OK?
}

- (NSDictionary*)parseStructure:(struct byte_buffer *)buff
{
    // pretend I'm virtual, OK?
    
    return nil;
}

@end
