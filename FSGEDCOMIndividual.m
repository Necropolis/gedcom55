//
//  FSGEDCOMIndividual.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/3/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMIndividual.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMIndividual

@synthesize individualId=_individualId;

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    // 0123456789
    // 0 @1@ INDI
    // 0 @I1@ INDI
    ByteBuffer * firstLine =
    [buff byteBufferWithRange:[buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]]];
    
    buff->_cursor=0;
    
    if (10>[firstLine length]) return NO; // can't possibly be right - the first line ain't long enough!
    
    voidPtr atSign =
    memchr(firstLine->_bytes, '@', firstLine->_length);
    if (NULL==atSign) return NO; // needs to have at least one.
    voidPtr secondAtSign =
    memchr(atSign, '@', atSign-firstLine->_bytes);
    if (NULL==secondAtSign) return NO; // needs to have at least two
    
    if (0==memcmp(&firstLine->_bytes[firstLine->_length-4], "INDI", 4))
        return YES; // totally an INDI record
    
    return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    return [[self class] respondsTo:buff];
}

- (void)postParse:(FSGEDCOM *)dg
{
    NSString * tmp = self.value;
    self.value = self.key;
    self.key = tmp;
    self.individualId = [self.value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
}

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
