//
//  FSGEDCOMStructure.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

struct byte_buffer; // fwd ref
struct byte_sequence; // fwd ref

@interface FSGEDCOMStructure : NSObject

+ (NSMutableArray*)registeredSubclasses;

+ (struct byte_sequence)respondsTo;
- (struct byte_sequence)respondsTo;

- (NSDictionary*)parseStructure:(struct byte_buffer*)buff;

@end
