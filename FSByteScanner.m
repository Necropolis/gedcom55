//
//  FSByteScanner.c
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#include "FSByteScanner.h"

NSRange scan_until_one_of(struct byte_buffer* scanner, struct byte_sequence sequences[], size_t num_sequences)
{
    NSRange ret = NSMakeRange(scanner->cursor, 0);
    ssize_t scan_not_found=-1;
    ssize_t* scan_status = (ssize_t*)malloc(sizeof(ssize_t)*num_sequences);
    for (size_t i=0; i<num_sequences; ++i) scan_status[i]=scan_not_found;
    size_t i;
    
    while (ret.length + scanner->cursor < scanner->length) {
        
        for (i=0;
             i < num_sequences;
             ++i) {
            struct byte_sequence seq = sequences[i];
            if (memcmp(&scanner->bytes[ret.length+scanner->cursor], seq.bytes, seq.length)) {
//            if (((ushort*)scanner->bytes)[ret.length+scanner->cursor] == ((ushort*)(seq.bytes))[scan_status[i]+1]) {
                // match found
                if (++scan_status[i] == seq.length) {
                    // found the whole thing!1!
                    scanner->cursor += ret.length+1;
                    free(scan_status);
                    return ret;
                }
            } else {
                scan_status[i] = scan_not_found;
            }
            
        }
        
        ++ret.length;
        
    }
    
    scanner->cursor += ret.length+1;
    free(scan_status);
    
    return ret;
}
