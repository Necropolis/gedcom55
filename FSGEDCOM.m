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
    
    // GEDCOM 5.5 does not define an encoding type! It may be of mixed encoding!
    
    // Current battle plan:
    // Scan through, byte by byte! The plumbing that defines the structure is all ASCII, so that'll
    // live on 8-bit boundaries. The user-input data may not, however. It may include any number of
    // diverse encodings, so those will be reconstructed and passed on to NSString after using Carbon's
    // Text Encoding Conversion Manager http://developer.apple.com/library/mac/#documentation/Carbon/Reference/Text_Encodin_sion_Manager/Reference/reference.html
    // to run through and determine a likely encoding.
    // There are multi-line strings in GEDCOM 5.5, so these will need to be reconstructed at the byte-
    // level. Particularly, I'm not confident that Foundation will be able to reconstruct split
    // graphemes with reasonable success.
    
    struct byte_buffer* buff = FSMakeByteBuffer([data bytes], [data length], 0);
    
    NSRange firstLine= FSByteBufferScanUntilOneOfSequence(buff, _newline_sequences, _t_newline_sequences);
    
    NSString* str = [NSString stringWithCharacters:&buff->bytes[firstLine.location] length:firstLine.length];
    NSLog(@"First line: %@", str);
    
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
