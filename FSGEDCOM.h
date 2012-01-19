//
// FSGEDCOM.h
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

struct byte_sequence; // forward declaration

@interface FSGEDCOM : NSObject

@property (readwrite, assign) struct byte_sequence* newline_sequences;

- (NSDictionary*)parse:(NSData*)data;

@end
