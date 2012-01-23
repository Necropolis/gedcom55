//
//  FSGEDCOMHead.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMHead.h"

#import "FSByteScanner.h"

@implementation FSGEDCOMHead

+ (void)load { [super load]; }

+ (struct byte_sequence)respondsTo
{
    struct byte_sequence seq = {
        .bytes = "0 HEAD",
        .length = 6
    }; // don't worry, it's stuck in code as a .data block!
    return seq;
}

- (NSDictionary*)parseStructure:(struct byte_buffer *)buff
{
    // do something here...
    NSLog(@"About to parse GEDCOM HEAD using %@", FSNSStringFromByteBuffer(*buff));
    return nil;
}

@end
