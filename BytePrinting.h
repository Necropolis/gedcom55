//
//  FSByteScanner.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* FSNSStringFromBytes(const voidPtr, size_t); /// obtain a string of hex
NSString* FSNSStringFromBytesAsASCII(const voidPtr, size_t); // obtain a string of stuff
