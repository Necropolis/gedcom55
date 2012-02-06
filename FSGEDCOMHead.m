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

@implementation FSGEDCOMHead

@synthesize charset=_charset;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s appendFormat:@"%@{\n", indent];
    
    [s appendFormat:@"%@    _recordType = %@;\n", indent, self.recordType];
    [s appendFormat:@"%@    _recordBody = %@;\n", indent, self.recordBody];
    [s appendFormat:@"%@    _charset = %@;\n", indent, [_charset descriptionWithLocale:locale indent:level+1]];
    [s appendFormat:@"%@    _parsedOffset = %lu;\n", indent, self->_parsedOffset];
    [s appendFormat:@"%@    _elements = %@;\n", indent, [self.elements descriptionWithLocale:locale indent:level+1]];
    
    [s appendFormat:@"%@}", indent];
    
    return s;
}

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    if (0==memcmp(buff->_bytes, "0 HEAD", 6)) return YES;
    else return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes, "0 HEAD", 6)) return YES;
    else return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{   // everything is in elements; now to make sense of it
    // See 55GEDCOM.pdf page 24
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
    
    self.charset = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"CHAR"];
}

- (NSString *)recordType { return @"HEAD"; }

#pragma mark - NSObject

+ (void)load { [super load]; }

@end

@implementation FSGEDCOMCharset

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s appendFormat:@"%@{\n%@    _recordType = %@;\n", indent, indent, self.recordType];
    [s appendFormat:@"%@    _recordBody = %@;\n", indent, self.recordBody];
    [s appendFormat:@"%@    _parsedOffset = %lu;\n", indent, self->_parsedOffset];
    [s appendFormat:@"%@    _hasMoreElements = %@;\n", indent, (0<[self.elements count])?@"YES":@"NO"];
    [s appendFormat:@"%@}", indent];
    
    return s;
}

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "CHAR", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
