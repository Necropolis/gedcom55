//
//  FSByteScanner.c
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#include "FSByteScanner.h"

NSRange scan_until_one_of(struct byte_buffer* scanner, struct byte_sequence* sequences, size_t num_sequences)
{
    NSRange ret = NSMakeRange(scanner->cursor, 0);
    enum { scan_not_found=-1 };
    ssize_t* scan_status = (ssize_t*)malloc(sizeof(ssize_t)*num_sequences);
    memset((void*)scan_status, scan_not_found, sizeof(ushort)*num_sequences);
    size_t i;
    
    while (ret.length + scanner->cursor < scanner->length) {
        
        for (i=0;
             i < num_sequences;
             ++i) {
            
            if (((ushort*)scanner->bytes)[ ret.length + scanner->cursor ] == ((ushort*)(sequences[i].bytes))[scan_status[i]+1]) {
                // match found
                if (++scan_status[i] == sequences[i].length) {
                    // found the whole thing!1!
                    scanner->cursor += ret.length+1;
                    return ret;
                }
            } else {
                scan_status[i] = scan_not_found;
            }
            
        }
        
        ++ret.length;
        
    }
    
    scanner->cursor += ret.length+1;
    
    return ret;
}
