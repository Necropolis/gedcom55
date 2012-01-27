//
// FSGEDCOM.m
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

#include <objc/runtime.h>

#import "FSGEDCOMStructure.h"
#import "ByteBuffer.h"
#import "ByteSequence.h"
#import "FSByteScanner.h"

@interface FSGEDCOM (__parser_common__)

+ (NSArray*)allStructureClasses;

- (FSGEDCOMStructure*)parseStructure:(struct byte_buffer*)buff;

@end

@implementation FSGEDCOM

- (NSDictionary*)parse:(NSData*)data
{
    // TODO: Scan through the GEDCOM, line by line!
    // Use FSByteScanner to do this!
    
    // GEDCOM 5.5 defines an encoding type of Unicode (probably UTF-8), but older files may use ANSEL
    
    // Current battle plan:
    // Scan through, byte by byte! The plumbing that defines the structure is all ASCII, so that'll
    // live on 8-bit boundaries. The user-input data may not, however.
    // There are multi-line strings in GEDCOM 5.5, so these will need to be reconstructed at the byte-
    // level. Particularly, I'm not confident that Foundation will be able to reconstruct split
    // graphemes with reasonable success, so that level of data-smashing will probably be done in C
    // and then the combined void* region will be passed through to NSString.
    
    NSMutableDictionary* warn_and_err = [[NSMutableDictionary alloc] init];
    
    ByteBuffer* _buff = [[ByteBuffer alloc] initWithBytes:(const voidPtr)[data bytes] cursor:0 length:[data length] copy:YES];
        
    uint8 ansel_or_ascii[] = { 0x30, 0x20       }; BOOL is_ansel_or_ascii = 0==memcmp(_buff.bytes, ansel_or_ascii, 2);
    uint8 utf8[]           = { 0xEF, 0xBB, 0xBF }; BOOL is_utf8           = 0==memcmp(_buff.bytes, utf8,           3);
    uint8 unicode1[]       = { 0x30, 0x00       }; BOOL is_unicode1       = 0==memcmp(_buff.bytes, unicode1,       2);
    uint8 unicode2[]       = { 0x00, 0x30       }; BOOL is_unicode2       = 0==memcmp(_buff.bytes, unicode2,       2);
    
    if (is_ansel_or_ascii) {
        [warn_and_err setObject:@"I don't support ANSEL or ASCII encoding. Sorry." forKey:FSGEDCOMErrorCode.UnsupportedEncoding];
        return warn_and_err;
    } else if (!is_unicode1 && !is_unicode2 && !is_utf8) { // not fatal, however the behavior is undefined.
        [warn_and_err setObject:@"Data lacks a header byte pattern for Unicode support (per pg. 63-64 of GEDCOM 5.5 spec). If this isn't Unicode, then the behavior of the parse is undefined and the program may crash." forKey:FSGEDCOMErrorCode.UnknownEncoding];
    }
    
    if (is_utf8) _buff.cursor += 3;
    else if (is_unicode1||is_unicode2) _buff.cursor += 2;
    
    NSRange r; ByteBuffer * _subbuffer;
    while ([_buff hasMoreBytes]) {
        r = [_buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:0]];
        _subbuffer = [_buff byteBufferWithRange:r];
        [_subbuffer scanUntilNotOneOfBytes:"\r\n" length:2];
        [_buff scanUntilNotOneOfBytes:"\r\n" length:2];
        NSLog(@"record buffer: %@", _subbuffer);
        NSLog(@"main buffer: %@", _buff);
    }
//    NSRange r = FSByteBufferScanUntilOneOfSequence(buff, FSByteSequencesNewlinesLongWithPrefix__cached(0).sequences, FSByteSequencesNewlinesLongWithPrefix__cached(0).length);
//    
//    NSLog(@"range: %@", NSStringFromRange(r));
//    
//    [self parseStructure:buff];
    
    return warn_and_err;
}

#pragma mark Parser Common

- (FSGEDCOMStructure*)parseStructure:(struct byte_buffer*)buff
{
    // Decide what kind of structure this is and hand off to the next parser accordingly.
    
    // detect next line ending
    size_t cur = buff->cursor;
    NSRange lineRange=
    FSByteBufferScanUntilOneOfSequence(buff, FSByteSequencesNewlinesLong().sequences, FSByteSequencesNewlinesLong().length);
    // create a new dummy byte_buffer that thinks it ends at the line ending
    struct byte_buffer* dbuff = FSMakeByteBuffer(buff->bytes, lineRange.length+lineRange.location, cur);
    
    for (Class c in [FSGEDCOMStructure registeredSubclasses]) {
        // scan for the respondsTo byte_sequence in the dummy byte_buffer
        if (NSNotFound!=FSByteBufferHasByteSequence(*dbuff, [c respondsTo])) {
            // parse using c
            FSGEDCOMStructure* s = [[c alloc] init];
            [s parseStructure:buff];
            break;
        }
    }
    
    // if the cursor for buff is beyond the cursor for the dummy buffer, then nothing responded to this structure; output some information and throw an error
    
    free(dbuff); // not used anymore
    
    return nil;
}

#pragma mark NSObject

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    return self;
}

@end
