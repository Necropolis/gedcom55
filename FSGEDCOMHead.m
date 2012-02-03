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
    
    NSArray * atMostOneOf = [NSArray arrayWithObjects:
                             @"SOUR.VERS",
                             @"SOUR.NAME",
                             @"SOUR.CORP",
                             @"SOUR.DATA",
                             @"SOUR.DATA.DATE",
                             @"SOUR.DATA.COPR",
                             @"DEST",
                             @"DATE",
                             @"DATE.TIME",
                             @"SUBN",
                             @"FILE",
                             @"COPR",
                             @"CHAR.VERS",
                             @"LANG",
                             @"PLAC",
                             @"NOTE"
                             , nil];
    
    for (NSString * atMostOneOfKey in atMostOneOf)
        if (nil!=[self.elements valueForKeyPath:atMostOneOfKey]) if (1<[[self.elements valueForKeyPath:atMostOneOfKey] count])
            [dg addWarning:[NSString stringWithFormat:@"HEAD record has more than one %@ substructure, which is illegal per the GEDCOM spec.", atMostOneOfKey] ofType:@"tooManyElements"];
    
    if (nil!=[self.elements objectForKey:@"PLAC"]&&(nil==[self.elements valueForKeyPath:@"PLAC.FORM"]||1<[[self.elements valueForKeyPath:@"PLAC.FORM"] count]))
        [dg addWarning:@"HEAD record's PLAC substructure lacks a FORM definition or has too many of them, which is illegal per the GEDCOM spec." ofType:@"specBreach"];
}

- (NSString *)recordType { return @"HEAD"; }

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
