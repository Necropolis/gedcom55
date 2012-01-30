//
//  ByteBuffer.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/26/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ByteSequence;

/**
 * Utility class for parsing through streams of bytes.
 *
 * GEDCOM lines are not specified for whether they are to be split in the middle of graphemes, necessitating the parsing through at the byte level instead of using Cocoa Text.
 */
@interface ByteBuffer : NSObject {
@public
    voidPtr _bytes;
    size_t _cursor;
    size_t _length;
}

@property (readwrite, assign) voidPtr bytes;
@property (readwrite, assign) size_t cursor;
@property (readwrite, assign) size_t length;
@property (readwrite, strong) ByteBuffer * parent;

- (id)initWithBytes:(const voidPtr)bytes cursor:(size_t)cursor length:(size_t)length copy:(BOOL)cpy;

- (NSRange)scanUntilOneOfByteSequences:(NSArray *)sequences;
- (NSRange)skipNewlines;
- (NSRange)skipLine;
- (NSRange)scanUntilNotOneOfBytes:(const voidPtr)bytes length:(size_t)length;

- (id)byteBufferWithRange:(NSRange)range;

- (BOOL)hasMoreBytes;

@end
