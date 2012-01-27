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

+ (NSMutableArray*)registeredSubclasses;

+ (BOOL)respondsTo:(ByteBuffer *)buff;

- (NSDictionary*)parseStructure:(ByteBuffer *)buff;

@end
