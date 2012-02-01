//
//  FSGEDCOMStructure.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSGEDCOM.h"
#import "NSContainers+DebugPrint.h"

@class ByteBuffer;

extern NSString * kLongLines;
extern size_t kMaxLineLength;

@interface FSGEDCOMStructure : NSObject <FSDescriptionDict>

// A dict of all the elements in the structure which the subclass doesn't know how to parse
@property (readwrite, strong) NSMutableDictionary * elements;

+ (NSMutableArray*)registeredSubclasses;
+ (Class)structureRespondingToByteBuffer:(ByteBuffer *)buff;

+ (BOOL)respondsTo:(ByteBuffer *)buff;

- (void)parseStructure:(ByteBuffer *)buff withLevel:(size_t)level delegate:(FSGEDCOM *)dg; // you probably don't want to override this

- (void)postParse:(FSGEDCOM *)dg; // subclasses will want to implement this, called after parseStructure. Run through elements to pull out specific kinds of data you want in a more scema-strong layout.

- (NSString *)recordType;
- (NSString *)recordBody;

@end
