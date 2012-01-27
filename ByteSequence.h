//
//  ByteSequence.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/26/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Represents a sequence of bytes; freed on dealloc.
 */
@interface ByteSequence : NSObject {
@public
    voidPtr _bytes;
    size_t _length;
}

@property (readwrite, assign) voidPtr bytes;
@property (readwrite, assign) size_t length;

+ (id)newlineByteSequencesWithIntegerPrefix:(size_t)pfx;
+ (id)newlineByteSequences;

- (id)initWithBytes:(const voidPtr)bytes length:(size_t)length; // copies bytes

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;

@end
