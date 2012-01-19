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
 */
struct byte_buffer {
    void* bytes;
    size_t length;
    size_t cursor;
};

/**
 * Used for searching.
 */
struct byte_sequence {
    void* bytes;
    size_t length;
};

/**
 * Scans from byte_buffer's cursor until one of the byte sequences is encountered. Returns the range of the bytes in the byte_buffer, and advances cursor ahead to the end of the scanned bytes.
 *
 * @param struct byte_buffer* The buffer to scan through.
 * @param struct byte_sequence* An array of byte sequences.
 * @param size_t The number of byte sequences.
 */
NSRange scan_until_one_of(struct byte_buffer*, struct byte_sequence*, size_t);
