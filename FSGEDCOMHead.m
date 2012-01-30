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
- (void)parseDestination:(ByteBuffer *)buff;
- (void)parseDate:(ByteBuffer *)buff;
- (void)parseFile:(ByteBuffer *)buff;
- (void)parseGedc:(ByteBuffer *)buff;
- (void)parseCharset:(ByteBuffer *)buff;

@end

@implementation FSGEDCOMHead

@synthesize source=_source;

- (void)parseSource:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a source record part at %@", buff);
}

- (void)parseDestination:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a destination record part at %@", buff);
}

- (void)parseDate:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a date record part at %@", buff);
}

- (void)parseFile:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a file record part at %@", buff);
}

- (void)parseGedc:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a GEDC record part at %@", buff);
}

- (void)parseCharset:(ByteBuffer *)buff
{
    NSLog(@"I'm about to parse a charset record part at %@", buff);
}

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    if (0==memcmp(buff->_bytes, "0 HEAD", 6)) return YES;
    else return NO;
}

- (NSDictionary*)parseStructure:(ByteBuffer *)buff withLevel:(size_t)level
{
    NSRange r; ByteBuffer * recordPart;
    
    [buff skipLine]; // fast-forward through the first line
    
    while ([buff hasMoreBytes]) {
        [buff skipNewlines];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:level+1]];
        recordPart = [buff byteBufferWithRange:r];
        Class c = [[self class] structureRespondingToByteBuffer:recordPart];
        FSGEDCOMStructure * s = [[c?:[FSGEDCOMStructure class] alloc] init];
        [s parseStructure:recordPart withLevel:level+1];
        recordPart->_cursor=0;
        NSLog(@"Found record bit of type %@ at %@", [s recordType], recordPart);
    }

    return nil;
}

- (NSString *)recordType
{
    return @"HEAD";
}

#pragma mark - NSObject

//+ (void)load { [super load]; }

@end
