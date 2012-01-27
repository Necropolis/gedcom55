//
//  ByteBuffer.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/26/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "ByteBuffer.h"

#import "ByteSequence.h"

#import "FSByteScanner.h" // for FSNSStringFromBytes(const voidPtr, size_t)
// for FSNSStringFromBytesAsASCII(const voidPtr, size_t)

@implementation ByteBuffer {
    BOOL _freeOnDealloc;
}

@synthesize bytes=_bytes;
@synthesize cursor=_cursor;
@synthesize length=_length;
@synthesize parent=_parent;

- (id)initWithBytes:(const voidPtr)bytes cursor:(size_t)cursor length:(size_t)length copy:(BOOL)cpy
{
    self = [super init];
    if (!self) return nil;
    
    if (cpy) {
        self.bytes = malloc(sizeof(void)*length);
        memcpy(_bytes, bytes, length);
        _freeOnDealloc = YES;
    } else {
        self.bytes = bytes;
        _freeOnDealloc = NO;
    }
    self.cursor = cursor;
    self.length = length;
    
    return self;
}

- (NSRange)scanUntilOneOfByteSequences:(NSArray *)sequences
{
    NSRange ret = NSMakeRange(_cursor, 0);
    size_t i; NSUInteger num_sequences = [sequences count];
    ByteSequence * b;
    
    while (ret.length + _cursor < _length) {
        
        for (i=0;
             i < num_sequences;
             ++i) { // memcmp can be assumed to be quite performant
            b = [sequences objectAtIndex:i];
            if (0==memcmp(&self->_bytes[ret.length+_cursor], b->_bytes, b->_length)) {
                _cursor += ret.length+1;
                return ret;
            }
        }
        
        ++ret.length;
        
    }
    
    _cursor += ret.length+1;
    
    return ret;
}

- (NSRange)scanUntilNotOneOfBytes:(const voidPtr)bytes length:(size_t)length
{
    NSRange ret = NSMakeRange(_cursor, 0);
    register size_t i; register BOOL k;
    
    while (ret.length + _cursor < _length) {
        k = NO;
        
        for (i=0;
             i < length;
             ++i) if (((uint8*)_bytes)[_cursor+ret.length]==((uint8*)bytes)[i]) k=YES;
        
        if (!k) {
            _cursor+=ret.length;
            return ret;
        }
        
        ret.length++;
    }
    
    // no match
    _cursor += ret.length;
    return ret;
}

- (id)byteBufferWithRange:(NSRange)range
{
    ByteBuffer * buff=[[ByteBuffer alloc] initWithBytes:&_bytes[range.location] cursor:0 length:MIN(range.length, _length-range.location) copy:NO];
    buff.parent = self;
    return buff;
}

- (BOOL)hasMoreBytes
{
    return _cursor < _length;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    static size_t peek_len = 16;
    NSMutableString* __indent = [NSMutableString stringWithCapacity:4*level];
    for (NSUInteger i=0; i<level; ++i) [__indent appendString:@"    "];
    return [NSString stringWithFormat:@"{\n%@    length: %lu,\n%@    cursor: %lu,\n%@    bytes: %@,\n%@    ASCII: %@\n}",
            __indent,
            _length,
            __indent,
            _cursor,
            __indent,
            FSNSStringFromBytes(_bytes+_cursor, MIN(peek_len, _length-_cursor)),
            __indent,
            FSNSStringFromBytesAsASCII(_bytes+_cursor, MIN(peek_len, _length-_cursor))];
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

- (void)dealloc
{   // do not nuke my parent's buffer!
    if (_freeOnDealloc&&nil==self.parent) free(_bytes);
}

@end