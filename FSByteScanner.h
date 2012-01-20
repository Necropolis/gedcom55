//
//  FSByteScanner.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Holds a position in a buffer of bytes (ideally inside of an NSData object). Does NOT own the buffer. It is designed to be used to hold a range of information, plus where in the range it is.
 *
 * Generally passed as references instead of on the stack (which copies) because then any changes do not propogate to the other structures.
 */
struct byte_buffer {
    const void* bytes;
    size_t length;
    size_t cursor;
};

/**
 * Used for searching.
 */
struct byte_sequence {
    const void* bytes;
    size_t length;
};

/**
 * Think of this like the regex /[a-z]/ or /[A-Z]/ construct. Make arrays of this to get fancy bits like /[a-zA-Z]/.
 */
struct char_range {
    unsigned char begin;
    unsigned char end;
};

/**
 * Makes a new heap-allocated byte_buffer pointing to const void* bytes with a buffer of size_t length and size_t cursor position.
 *
 * @param const void* The bytes pointed to.
 * @param size_t The length of the buffer.
 * @param size_t The cursor position in the buffer.
 */
struct byte_buffer* FSMakeByteBuffer(const void*, size_t, size_t);

/**
 * Scans from byte_buffer's cursor until one of the byte sequences is encountered. Returns the range of the bytes between byte_buffer's cursor and the found pattern, and advances cursor ahead to the end of the scanned bytes.
 *
 * @param struct byte_buffer* The buffer to scan through.
 * @param struct byte_sequence[] An array of byte sequences.
 * @param size_t The number of byte sequences.
 */
NSRange FSByteBufferScanUntilOneOfSequence(struct byte_buffer*, struct byte_sequence[], size_t);

/**
 * Scans from byte_buffer's cursor until a character in a given range is encountered. Returns the range of the bytes between byte_buffer's cursor and the found character, and advances the cursor ahead to the end of the scanned bytes.
 *
 * @param struct byte_buffer* The buffer to scan through.
 * @param struct char_range[] An array of character ranges.
 * @param size_t The number of character ranges.
 */
NSRange FSByteBufferScanUntilOneOfCharRanges(struct byte_buffer*, struct char_range[], size_t);

NSString* FSNSStringFromByteBuffer(struct byte_buffer*); /// obtain pretty text
NSString* FSNSStringFromByteSequence(struct byte_sequence*); /// obtain pretty text
NSString* FSNSStringFromCharRange(struct char_range); /// obtain pretty text
NSString* FSNSStringFromBytes(const void*, size_t); /// obtain a string of hex
NSString* FSNSStringFromBytesAsASCII(const void*, size_t); // obtain a string of stuff