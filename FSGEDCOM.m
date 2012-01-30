//
// FSGEDCOM.m
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

#import "FSGEDCOMStructure.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@interface FSGEDCOM (__parser_common__)

+ (NSArray*)allStructureClasses;

- (FSGEDCOMStructure*)parseStructure:(ByteBuffer *)buff;

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
        [_subbuffer skipNewlines];
        [_buff skipNewlines];
        FSGEDCOMStructure * structure = [self parseStructure:_subbuffer];
        if (structure==nil) {
            if (nil==[warn_and_err objectForKey:@"unknownRecords"]) { [warn_and_err setObject:[NSMutableArray array] forKey:@"unknownRecords"]; }
            [[warn_and_err objectForKey:@"unknownRecords"] addObject:[NSString stringWithFormat:@"Found an unidentifiable record at offset 0x%08qX", r.location]];
        }
    }
    
    return warn_and_err;
}

#pragma mark Parser Common

- (FSGEDCOMStructure*)parseStructure:(ByteBuffer *)buff
{
    Class c = [FSGEDCOMStructure structureRespondingToByteBuffer:buff];
    FSGEDCOMStructure * s = nil;
    if (c) s = [[c alloc] init];
    else s = [[FSGEDCOMStructure alloc] init];
    [s parseStructure:buff];
    return s;
}

#pragma mark NSObject

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    return self;
}

@end
