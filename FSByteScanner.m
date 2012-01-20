//
//  FSByteScanner.c
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#include "FSByteScanner.h"

struct byte_buffer* FSMakeByteBuffer(const void* bytes, size_t length, size_t cursor)
{
    struct byte_buffer* buff = malloc(sizeof(struct byte_buffer));
    buff->bytes = bytes;
    buff->length = length;
    buff->cursor = cursor;
    return buff;
}

NSRange FSByteBufferScanUntilOneOfSequence(struct byte_buffer* scanner, struct byte_sequence sequences[], size_t num_sequences)
{
    NSRange ret = NSMakeRange(scanner->cursor, 0);
    size_t i;
    
    while (ret.length + scanner->cursor < scanner->length) {
        
        for (i=0;
             i < num_sequences;
             ++i) { // memcmp can be assumed to be quite performant
            if (0==memcmp(&scanner->bytes[ret.length+scanner->cursor], sequences[i].bytes, sequences[i].length)) {
                scanner->cursor += ret.length+1;
                return ret;
            }
        }
        
        ++ret.length;
        
    }
    
    scanner->cursor += ret.length+1;
    
    return ret;
}

NSRange FSByteBufferScanUntilOneOfCharRanges(struct byte_buffer* scanner, struct char_range ranges[], size_t num_ranges)
{
    NSRange ret = NSMakeRange(scanner->cursor, 0);
    size_t i;
    
    while (ret.length + scanner->cursor < scanner->length) {
        
        for (i=0;
             i < num_ranges;
             ++i) {
            if (((unsigned char*)scanner   ->bytes)[ret.length + scanner->cursor] >= ranges[i].begin
                && ((unsigned char*)scanner->bytes)[ret.length + scanner->cursor] <= ranges[i].end) {
                scanner->cursor += ret.length;
                return ret;
            }
        }
        
        ++ret.length;
        
    }
    
    scanner->cursor += ret.length+1;
    
    return ret;
}

NSString* FSNSStringFromByteBuffer(struct byte_buffer* buff)
{
    NSMutableString* str = [NSMutableString stringWithFormat:@"{ length: %lu, cursor: %lu, bytes: ", buff->length, buff->cursor];
    [str appendString:FSNSStringFromBytes(buff->bytes+buff->cursor, MIN(16, buff->length))];
    [str appendString:@"}"];
    return str;
}
NSString* FSNSStringFromByteSequence(struct byte_sequence* seq);
NSString* FSNSStringFromCharRange(struct char_range ran);
NSString* FSNSStringFromBytes(const void* bytes, size_t len)
{
    NSMutableString* str = [NSMutableString stringWithCapacity:3*len];
    for (size_t i=0;
         i < len;
         ++i)
        [str appendFormat:@"%02hhx ", ((uint8*)bytes)[i]];
    return str;
}