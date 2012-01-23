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

size_t FSByteBufferHasByteSequence(const struct byte_buffer buff, const struct byte_sequence seq)
{
    for (size_t i=buff.cursor;
         i+seq.length<=buff.length;
         ++i) if (0==memcmp(&buff.bytes[i], seq.bytes, seq.length)) return i;
    return NSNotFound; // NSIntegerMax; not likely to be the real ret value
}

struct byte_sequence_array FSByteSequencesNewlinesShort()
{
    static struct byte_sequence_array b;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        b.sequences = malloc(sizeof(struct byte_sequence) * 2);
        b.sequences[0].bytes = "\r"  ; b.sequences[0].length= 1;
        b.sequences[1].bytes = "\n"  ; b.sequences[1].length= 1;
        b.length = 2;
    });
    return b;
}

struct byte_sequence_array FSByteSequencesNewlinesLong()
{
    static struct byte_sequence_array b;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        b.sequences = malloc(sizeof(struct byte_sequence) * 4);
        b.sequences[0].bytes = "\r\n"; b.sequences[0].length = 2;
        b.sequences[1].bytes = "\n\r"; b.sequences[1].length = 2;
        b.sequences[2].bytes = "\r"  ; b.sequences[2].length = 1;
        b.sequences[3].bytes = "\n"  ; b.sequences[3].length = 1;
        b.length = 4;
    });
    return b;
}

NSString* FSNSStringFromByteBuffer(struct byte_buffer* buff)
{
    size_t peek_len = 16;
    return [NSString stringWithFormat:@"{\n    length: %lu,\n    cursor: %lu,\n    bytes: %@,\n    ASCII: %@\n}",
            buff->length,
            buff->cursor,
            FSNSStringFromBytes(buff->bytes+buff->cursor, MIN(peek_len, buff->length-buff->cursor)),
            FSNSStringFromBytesAsASCII(buff->bytes+buff->cursor, MIN(peek_len, buff->length-buff->cursor))];
}

NSString* FSNSStringFromByteSequence(struct byte_sequence* seq)
{
    return [NSString stringWithFormat:@"{\n    length: %lu,\n    bytes: %@\n    ASCII: %@\n}",
            seq->length,
            FSNSStringFromBytes(seq->bytes, seq->length),
            FSNSStringFromBytesAsASCII(seq->bytes, seq->length)];
}

NSString* FSNSStringFromCharRange(struct char_range ran)
{
    return [NSString stringWithFormat:@"{ begin: %c end: %c }", ran.begin, ran.end];
}

NSString* FSNSStringFromBytes(const void* bytes, size_t len)
{
    NSMutableString* str = [NSMutableString stringWithCapacity:3*len];
    for (size_t i=0;
         i < len;
         ++i)
        [str appendFormat:@"%02hhx ", ((uint8*)bytes)[i]];
    [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
    return str;
}

NSString* FSNSStringFromBytesAsASCII(const void* bytes, size_t len)
{
    NSMutableString* str = [NSMutableString stringWithCapacity:3*len]; // guesstimate
    for (size_t i=0;
         i < len;
         ++i) {
        uint8 c = ((uint8*)bytes)[i];
        if (isgraph(c))      [str appendFormat:@" %c ",    c];
        else if (isspace(c)) {
            if (c=='\r')     [str appendString:@"\\r "      ];
            else if (c=='\n')[str appendString:@"\\n "      ];
            else if (c=='\v')[str appendString:@"\\v "      ];
            else if (c=='\f')[str appendString:@"\\f "      ];
            else if (c=='\t')[str appendString:@"\\t "      ];
            else if (c==' ' )[str appendString:@"sp "       ]; 
            else             [str appendFormat:@"%02hhx ", c];
        }
        else                 [str appendFormat:@"%02hhx ", c];
    }
    [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
    return str;
}
