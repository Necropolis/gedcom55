//
//  FSGEDCOMStructure.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ByteBuffer;

@interface FSGEDCOMStructure : NSObject

// A dict of all the elements in the structure which the subclass doesn't know how to parse
@property (readwrite, strong) NSMutableDictionary * elements;

+ (NSMutableArray*)registeredSubclasses;
+ (Class)structureRespondingToByteBuffer:(ByteBuffer *)buff;

+ (BOOL)respondsTo:(ByteBuffer *)buff;

- (NSDictionary*)parseStructure:(ByteBuffer *)buff;

- (NSString *)recordType;

@end
