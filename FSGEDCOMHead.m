//
//  FSGEDCOMHead.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMHead.h"

#import "FSGEDCOM.h"
#import "FSGEDCOM+ParserInternal.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMHead

@synthesize source=_source;
@synthesize gedcom=_gedcom;
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
    [s fs_appendDictionaryKey:@"_gedcom" value:_gedcom locale:locale indentString:indent indentLevel:level+1];
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
            [dg addWarning:[NSString stringWithFormat:@"HEAD record structure lacks a %@ entry. This is illegal per the GEDCOM spec.", requiredKey] ofType:FSGEDCOMErrorCode.MissingRequiredElement];
    
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
            [dg addWarning:[NSString stringWithFormat:@"HEAD record has more than one %@ substructure, which is illegal per the GEDCOM spec.", atMostOneOfKey] ofType:FSGEDCOMErrorCode.TooManyElements];
    
    if (nil!=[self.elements objectForKey:@"PLAC"]&&(nil==[self.elements valueForKeyPath:@"PLAC.FORM"]||1<[[self.elements valueForKeyPath:@"PLAC.FORM"] count]))
        [dg addWarning:@"HEAD record's PLAC substructure lacks a FORM definition or has too many of them, which is illegal per the GEDCOM spec." ofType:FSGEDCOMErrorCode.SpecificationBreach];
    
    self.source = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"SOUR"];
    self.gedcom = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"GEDC"];
    self.charset = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"CHAR"];
    FSGEDCOMStructure * __file = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"FILE"];
    self.file = !!__file?__file.value:nil;
    FSGEDCOMStructure * __destination = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"DEST"];
    self.destination = !!__destination?__destination.value:nil;
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end

@implementation FSGEDCOMHeaderSource
@synthesize name=_name;
@synthesize version=_version;
@synthesize corporation=_corporation;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_name" value:_name locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_version" value:_version locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_corporation" value:_corporation locale:locale indentString:indent indentLevel:level+1];
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
    FSGEDCOMStructure * __name, * __version;
    __name =    [self firstElementOfTypeAndRemoveKeyIfEmpty:@"NAME"];
    __version = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"VERS"];
    
    self.name       = !!__name      ?__name.value   :nil;
    self.version    = !!__version   ?__version.value:nil;
    self.corporation= [self firstElementOfTypeAndRemoveKeyIfEmpty:@"CORP"];
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMHeaderSourceCorporation
@synthesize phone=_phone;
@synthesize www=_www;
@synthesize email=_email;
@synthesize addr=_addr;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_phone" value:_phone locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_www" value:_www locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_email" value:_email locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_addr" value:_addr locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "CORP", 4) && [parent isKindOfClass:[FSGEDCOMHeaderSource class]]) return YES;
    else return NO;
}
- (void)postParse:(FSGEDCOM *)dg
{
    FSGEDCOMStructure * __phone, * __www, * __email, * __addr;
    __phone = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"PHON"   ];
    __www   = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"WWW"    ];
    __email = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"EMAIL"  ];
    __addr  = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"ADDR"   ];
    
    self.phone      = !!__phone     ?__phone.value  :nil;
    self.www        = !!__www       ?__www.value    :nil;
    self.email      = !!__email     ?__email.value  :nil;
    self.addr       = !!__addr      ?__addr.value   :nil; // Will drop other address elements from deprecated fields
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMHeaderGEDCOM
@synthesize version=_version;
@synthesize form=_form;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_version" value:_version locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_form" value:_form locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "GEDC", 4) && [parent isKindOfClass:[FSGEDCOMHead class]]) return YES;
    else return NO;
}
- (void)postParse:(FSGEDCOM *)dg
{
    FSGEDCOMStructure * __vers = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"VERS"], * __form = [self firstElementOfTypeAndRemoveKeyIfEmpty:@"FORM"];
    self.version = !!__vers?__vers.value:nil;
    self.form = !!__form?__form.value:nil;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end

@implementation FSGEDCOMHeaderCharset
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

@implementation FSGEDCOMHeaderCharsetVersion
#pragma mark FSGEDCOMStructure
+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }
+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    if (0==memcmp(buff->_bytes+2, "VERS", 4) && [parent isKindOfClass:[FSGEDCOMHeaderCharset class]]) return YES;
    else return NO;
}
#pragma mark NSObject
+ (void)load { [super load]; }
@end
