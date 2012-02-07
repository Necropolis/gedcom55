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

@synthesize source=_source;
@synthesize charset=_charset;
@synthesize file=_file;
@synthesize destination=_destination;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_source" value:_source locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_charset" value:_charset locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_file" value:_file locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_destination" value:_destination locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_elements" value:self.elements locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}

#pragma mark FSGEDCOMStructure

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
    
    self.source = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"SOUR"];
    self.charset = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"CHAR"];
    self.file = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"FILE"];
    self.destination = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"DEST"];
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end

@implementation FSGEDCOMHeaderSource
@synthesize name=_name;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_name" value:_name locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "SOUR", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}
- (void)postParse:(FSGEDCOM *)dg
{
    self.name = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"NAME"];
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMHeaderSourceName
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "NAME", 4) && [parent isKindOfClass:[FSGEDCOMHeaderSource class]]) return YES;
    else return NO;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMCharset
@synthesize charsetVersion=_charsetVersion;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_charsetVersion" value:self.charsetVersion locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];

    return s;
}
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "CHAR", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}
- (void)postParse:(FSGEDCOM *)dg
{
    self.charsetVersion = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"VERS"];
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMCharsetVersion
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "VERS", 4) && [parent isKindOfClass:[FSGEDCOMCharset class]]) return YES;
    else return NO;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMFile
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "FILE", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMDestination
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "DEST", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end