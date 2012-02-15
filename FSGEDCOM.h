//
// FSGEDCOM.h
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSGEDCOMFamily;
@class FSGEDCOMIndividual;

extern const struct FSGEDCOMErrorCode {
    __unsafe_unretained NSString * UnsupportedEncoding;
    __unsafe_unretained NSString * UnknownEncoding;
    __unsafe_unretained NSString * LongLine;
    __unsafe_unretained NSString * MissingRequiredElement;
    __unsafe_unretained NSString * TooManyElements;
    __unsafe_unretained NSString * SpecificationBreach;
    __unsafe_unretained NSString * TooManyPeople;
} FSGEDCOMErrorCode;

@interface FSGEDCOM : NSObject

@property (readwrite, strong) NSMutableArray * structures;
@property (readwrite, strong) NSMutableDictionary * individuals;
@property (readwrite, strong) NSMutableDictionary * families;

- (NSDictionary*)parse:(NSData*)data;

@end
