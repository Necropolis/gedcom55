//
//  FSGEDCOMFamily.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/13/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMFamily.h"

#import "FSGEDCOM+ParserInternal.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMFamily

#pragma mark FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    // 0123456789
    // 0 @1@ FAM
    // 0 @I1@ FAM
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
    
    if (0==memcmp(&firstLine->_bytes[firstLine->_length-4], " FAM", 4))
        return YES; // totally an INDI record
    
    return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{
    NSString * tmp = self.value;
    self.value = [self.key stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    self.key = tmp;
    [dg registerFamily:self];
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end
