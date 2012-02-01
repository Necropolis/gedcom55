//
//  FSGEDCOMHead.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMHead.h"

#import "FSGEDCOM.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@interface FSGEDCOMHead (__impl__) {
@private
    
}

@end

@implementation FSGEDCOMHead

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    if (0==memcmp(buff->_bytes, "0 HEAD", 6)) return YES;
    else return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{   // everything is in elements; now to make sense of it
    // See 55GEDCOM.pdf page 24
    NSLog(@"%@", [self.elements valueForKey:@"SOUR"
                  ]);
    NSArray * requiredKeys = [NSArray arrayWithObjects:
                              @"SOUR",
                              @"SUBM",
                              @"GEDC",
                              @"CHAR", nil];
    for (NSString * requiredKey in requiredKeys)
        if (nil==[self.elements valueForKey:requiredKey])
            [dg addWarning:[NSString stringWithFormat:@"HEAD record structure lacks a %@ entry. This is illegal per the GEDCOM spec.", requiredKey] ofType:@"missingRequiredElement"];
}

- (NSString *)recordType
{
    return @"HEAD";
}

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
