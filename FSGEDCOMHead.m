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

@interface FSGEDCOMHead (__impl__) {
@private
    
}

- (void)parseSource:(ByteBuffer *)buff;

@end

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
        if (0==memcmp(recordPart->_bytes, "1 SOUR ", 7)) { [self parseSource:recordPart]; }
        else {
            NSLog(@"Found record part at %@", recordPart);
        }
    }

    return nil;
}

- (void)parseSource:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a source record at %@", buff);
}

@end
