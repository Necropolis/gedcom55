//
//  FSGEDCOMFamily.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/13/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMFamily.h"

#import "FSGEDCOM+ParserInternal.h"
#import "FSGEDCOMIndividual.h"
#import "FSGEDCOMWeakProxy.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

#import "NSContainers+DebugPrint.h"

@implementation FSGEDCOMFamily

@synthesize husband=_husband;
@synthesize wife=_wife;
@synthesize children=_children;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:s locale:locale indentString:indent indentLevel:level];
    [s fs_appendDictionaryKey:@"_husband" value:_husband.value locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_wife" value:_wife.value locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_children" value:[_children valueForKeyPath:@"value"] locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}

#pragma mark FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    // 0123456789
    // 0 @1@ FAM
    // 0 @I1@ FAM
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
    
    if (0==memcmp(&firstLine->_bytes[firstLine->_length-4], " FAM", 4))
        return YES; // totally an INDI record
    
    return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{
    NSCharacterSet * atSign = [NSCharacterSet characterSetWithCharactersInString:@"@"];
    NSString * tmp = self.value;
    self.value = [self.key stringByTrimmingCharactersInSet:atSign];
    self.key = tmp;
    [dg registerFamily:self];
    // exchange key/value for husband, wife, & all children
    NSMutableArray * arr = [self.elements objectForKey:@"HUSB"];
    FSGEDCOMStructure * _rec = nil;
    if (arr) {
        if (1<[arr count]) [dg addWarning:@"Too many husbands in this family! Polygamy much?" ofType:FSGEDCOMErrorCode.TooManyPeople];
        _rec = [arr objectAtIndex:0];
        if (_rec) {
            _rec.value = [_rec.value stringByTrimmingCharactersInSet:atSign];
            [dg registerCallback:^(FSGEDCOMIndividual * husband) { self.husband = husband; } forIndividual:_rec.value]; // actually some pretty spiffy functional programming
        }
    }
    [self.elements removeObjectForKey:@"HUSB"]; // get rid of stupid old memory
    arr = [self.elements objectForKey:@"WIFE"];
    if (arr) {
        if (1<[arr count]) [dg addWarning:@"Too many wives in this family! Polygamy much?" ofType:FSGEDCOMErrorCode.TooManyPeople];
        _rec = [arr objectAtIndex:0];
        if (_rec) {
            _rec.value = [_rec.value stringByTrimmingCharactersInSet:atSign];
            [dg registerCallback:^(FSGEDCOMIndividual * wife) { self.wife = wife; } forIndividual:_rec.value];
        }
    }
    [self.elements removeObjectForKey:@"WIFE"]; // back in the kitchen! I mean... memory cleanup
    arr = [self.elements objectForKey:@"CHIL"]; // freakin children
    if (arr) {
        self.children = [[NSMutableArray alloc] initWithCapacity:[arr count]];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.children addObject:[NSNull null]];
            FSGEDCOMStructure * _rec = [arr objectAtIndex:idx];
            _rec.value = [_rec.value stringByTrimmingCharactersInSet:atSign];
            [dg registerCallback:^(FSGEDCOMIndividual * child) { [self.children replaceObjectAtIndex:idx withObject:[FSGEDCOMWeakProxy weakProxyWithObject:child]]; } forIndividual:_rec.value];
        }];
    }
    [self.elements removeObjectForKey:@"CHIL"]; // don't you wish killing all your children were that easy?
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end
