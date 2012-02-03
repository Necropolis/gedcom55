//
//  FSGEDCOMIndividual.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/3/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMIndividual.h"

#import "ByteBuffer.h"
#import "ByteSequence.m"

@implementation FSGEDCOMIndividual

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    // 0 @I1@ INDI
    
    
    return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{
    
}

- (NSString *)recordType { return @"INDI"; }

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
