//
//  FSGEDCOMHead.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMHead.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMHead

@synthesize source=_source;

+ (void)load { [super load]; }

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    if (0==memcmp(buff->_bytes, "0 HEAD", 6)) return YES;
    else return NO;
}

- (NSDictionary*)parseStructure:(ByteBuffer *)buff
{
    NSRange r; ByteBuffer * recordPart;
    
    // do something here...
    while ([buff hasMoreBytes]) {
        [buff scanUntilNextLine];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:1]];
        recordPart = [buff byteBufferWithRange:r];
        NSLog(@"Found record part at %@", recordPart);
    }
    
    NSLog(@"About to parse HEAD with %@", buff);
    
    
    
    return nil;
}

@end
