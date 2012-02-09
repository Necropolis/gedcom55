//
// FSGEDCOM.h
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct FSGEDCOMErrorCode {
    __unsafe_unretained NSString* UnsupportedEncoding;
    __unsafe_unretained NSString* UnknownEncoding;
} FSGEDCOMErrorCode;

@interface FSGEDCOM : NSObject

@property (readwrite, strong) NSMutableArray * structures;
@property (readwrite, strong) NSMutableDictionary * individuals;

- (NSDictionary*)parse:(NSData*)data;

- (void)addWarning:(NSString *)warning ofType:(NSString *)type;

@end
