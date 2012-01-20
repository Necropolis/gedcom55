//
// FSGEDCOM.h
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

struct byte_sequence; // forward declaration

extern const struct FSGEDCOMErrorCode {
    __unsafe_unretained NSString* UnsupportedEncoding;
    __unsafe_unretained NSString* UnknownEncoding;
} FSGEDCOMErrorCode;

@interface FSGEDCOM : NSObject

@property (readwrite, assign) struct byte_sequence* newline_sequences;
@property (readwrite, assign) size_t t_newline_sequences;

- (NSDictionary*)parse:(NSData*)data;

@end
