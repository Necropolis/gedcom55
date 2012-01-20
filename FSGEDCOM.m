//
// FSGEDCOM.m
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

#import "FSByteScanner.h"

@implementation FSGEDCOM

@synthesize newline_sequences=_newline_sequences;
@synthesize t_newline_sequences=_t_newline_sequences;

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
    
    struct byte_buffer* buff = FSMakeByteBuffer([data bytes], [data length], 0);
    
    struct char_range* numeric = malloc(sizeof(struct char_range));
    numeric[0].begin='0';
    numeric[0].end  ='9';
    
    NSRange beginOfFirstLine = FSByteBufferScanUntilOneOfCharRanges(buff, numeric, 1);
    
    NSLog(@"begin of first line: %@", NSStringFromRange(beginOfFirstLine));
    NSRange firstLine= FSByteBufferScanUntilOneOfSequence(buff, _newline_sequences, _t_newline_sequences);
    NSLog(@"first line: %@", NSStringFromRange(firstLine)); 
    NSString* str = [[NSString alloc] initWithBytes:&(buff->bytes[firstLine.location]) length:firstLine.length encoding:NSUTF8StringEncoding];
    NSLog(@"First line: %@", str);
    
    free(numeric);
    free(buff);
    
    return [NSDictionary dictionary];
}

#pragma mark NSObject

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    _newline_sequences = malloc(sizeof(struct byte_sequence)*2);
    _newline_sequences[0].bytes = "\n";
    _newline_sequences[0].length = 1;
    _newline_sequences[1].bytes = "\r";
    _newline_sequences[1].length = 1;
    _t_newline_sequences = 2;
    
    return self;
}

- (void)dealloc
{
    free(_newline_sequences);
}

@end
