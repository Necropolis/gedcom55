//
//  FSGEDCOMIndividual.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/3/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMIndividual.h"

#import "FSGEDCOM+ParserInternal.h"
#import "FSGEDCOMWeakProxy.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMIndividual

@synthesize familiesWhereChild=_familiesWhereChild;
@synthesize familiesWhereSpouse=_familiesWhereSpouse;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_familiesWhereChild" value:[_familiesWhereChild valueForKey:@"value"] locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_familiesWhereSpouse" value:[_familiesWhereSpouse valueForKey:@"value"] locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}

#pragma mark - FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    // 0123456789
    // 0 @1@ INDI
    // 0 @I1@ INDI
    ByteBuffer * firstLine =
    [buff byteBufferWithRange:[buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]]];
    
    buff->_cursor=0;
    
    if (10>[firstLine length]) return NO; // can't possibly be right - the first line ain't long enough!
    
    voidPtr atSign =
    memchr(firstLine->_bytes, '@', firstLine->_length);
    if (NULL==atSign) return NO; // needs to have at least one.
    voidPtr secondAtSign =
    memchr(atSign, '@', atSign-firstLine->_bytes);
    if (NULL==secondAtSign) return NO; // needs to have at least two
    
    if (0==memcmp(&firstLine->_bytes[firstLine->_length-5], " INDI", 5))
        return YES; // totally an INDI record
    
    return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    return [[self class] respondsTo:buff];
}

- (void)postParse:(FSGEDCOM *)dg
{
    NSString * tmp = self.value;
    self.value = [self.key stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    self.key = tmp;
    [dg registerIndividual:self];
    NSMutableArray * arr = [self.elements objectForKey:@"FAMC"];
    if (arr) {
        self.familiesWhereChild = [[NSMutableArray alloc] initWithCapacity:[arr count]];
        for (NSUInteger i=0;
             i<[arr count];
             ++i) [_familiesWhereChild addObject:[NSNull null]];
        for (NSUInteger i=0;
             i<[arr count];
             ++i) {
            FSGEDCOMStructure * _rec = [arr objectAtIndex:i];
            _rec.value = [_rec.value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            [dg registerCallback:^(FSGEDCOMFamily * family) { [_familiesWhereChild replaceObjectAtIndex:i withObject:[FSGEDCOMWeakProxy weakProxyWithObject:family]]; } forFamily:_rec.value];
        }
    }
    [self.elements removeObjectForKey:@"FAMC"];
    arr = [self.elements objectForKey:@"FAMS"];
    if (arr) {
        self.familiesWhereSpouse = [[NSMutableArray alloc] initWithCapacity:[arr count]];
        for (NSUInteger i=0;
             i<[arr count];
             ++i) [_familiesWhereSpouse addObject:[NSNull null]];
        for (NSUInteger i=0;
             i <[arr count];
             ++i) {
            FSGEDCOMStructure * _rec = [arr objectAtIndex:i];
            _rec.value = [_rec.value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            [dg registerCallback:^(FSGEDCOMFamily * family) { [_familiesWhereSpouse replaceObjectAtIndex:i withObject:[FSGEDCOMWeakProxy weakProxyWithObject:family]]; } forFamily:_rec.value];
        }
    }
    [self.elements removeObjectForKey:@"FAMS"];
}

#pragma mark - NSObject

+ (void)load { [super load]; }

@end
