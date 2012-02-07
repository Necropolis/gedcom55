//
//  FSGEDCOMStructure.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMStructure.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"
#import "BytePrinting.h"

NSString * kLongLines = @"longLines";
size_t kMaxLineLength = 255;

@implementation FSGEDCOMStructure

@synthesize key=_key;
@synthesize value=_value;

@synthesize elements=_elements;

+ (NSMutableArray*)registeredSubclasses
{
    static NSMutableArray* registeredSubclasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredSubclasses = [[NSMutableArray alloc] init];
    });
    return registeredSubclasses;
}

+ (Class)structureRespondingToByteBuffer:(ByteBuffer *)buff
{
    for (Class c in [FSGEDCOMStructure registeredSubclasses])
        if ([c respondsTo:buff])
            return c;
    return nil;
}

+ (Class)structureRespondingToByteBuffer:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    for (Class c in [FSGEDCOMStructure registeredSubclasses])
        if ([c respondsTo:buff parentObject:parent])
            return c;
    return nil;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff
{
    [NSException raise:@"Pure Virtual Called" format:@"%s is supposed to be pure-virtual", __PRETTY_FUNCTION__];
    return NO;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    [NSException raise:@"Pure Virtual Called" format:@"%s is supposed to be pure-virtual", __PRETTY_FUNCTION__];
    return NO;
}

- (void)parseStructure:(ByteBuffer *)buff withLevel:(size_t)level delegate:(FSGEDCOM *)dg
{ @autoreleasepool {
    _parsedOffset = [buff globalOffsetOfByte:0];
    NSRange r; ByteBuffer * recordPart; NSMutableArray * __elements = [[NSMutableArray alloc] init];
    
    r = [buff skipLine]; // skip line prevents infinite recursion
    
    // work with that thar line
    recordPart = [buff byteBufferWithRange:r];
    [recordPart scanUntilOneOfByteSequences:[ByteSequence whitespaceByteSequences]];
    NSString * line = [recordPart stringFromRange:NSMakeRange(0, recordPart->_length) encoding:NSUTF8StringEncoding];
//    if (NSNotFound!=[line rangeOfString:@"INDI"].location)
//        NSLog(@"Line: %@", line);
    size_t l = [line length];
    if (l>=kMaxLineLength) {
        [dg addWarning:[NSString stringWithFormat:@"Found a line of length %lu which is longer than %lu beginning at offset %lu", l, kMaxLineLength, [recordPart globalOffsetOfByte:0]] ofType:kLongLines];
    }
    NSRange _recordTypeRange = [recordPart scanUntilOneOfByteSequences:[[ByteSequence newlineByteSequences] arrayByAddingObjectsFromArray:[ByteSequence whitespaceByteSequences]]];
    NSRange _recordBodyRange = [recordPart scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]];
    self.key = [recordPart stringFromRange:_recordTypeRange encoding:NSUTF8StringEncoding];
    self.value = [recordPart stringFromRange:_recordBodyRange encoding:NSUTF8StringEncoding];
    // keeping the code around, but commented because it can be useful in debugging later
//    if (NSNotFound!=[line rangeOfString:@"INDI"].location) {
//        NSLog(@"Record Type Range: %@", NSStringFromRange(_recordTypeRange));
//        NSLog(@"Record Type:       %@", _recordType);
//        NSLog(@"Record Body Range: %@", NSStringFromRange(_recordBodyRange));
//        NSLog(@"Record Body:       %@", _recordBody);
//    }
    
    while ([buff hasMoreBytes]) {
        [buff skipNewlines];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:level+1]];
        recordPart = [buff byteBufferWithRange:r];
        Class c = [[self class] structureRespondingToByteBuffer:recordPart parentObject:self];
        FSGEDCOMStructure * s = [[c?:[FSGEDCOMStructure class] alloc] init];
        [s parseStructure:recordPart withLevel:level+1 delegate:dg];
        recordPart->_cursor=0;
        [__elements addObject:s];
    }
    
// comment me out to stop the printfs!
//#define BODY_CHANGED_PRINTFS
#ifdef BODY_CHANGED_PRINTFS
    __block BOOL bodyChanged = NO;
#endif
    __block NSMutableArray * toRemove = [NSMutableArray array];
    [__elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSGEDCOMStructure class]]) return;
        FSGEDCOMStructure * s = (FSGEDCOMStructure *)obj;
        NSMutableString * recordBody = [[NSMutableString alloc] initWithString:_value];
        if ([[s key] isEqualToString:@"CONT"]) { // continued
            [recordBody appendFormat:@"\n%@", [s value]];
            [toRemove addObject:obj];
#ifdef BODY_CHANGED_PRINTFS
            bodyChanged = YES;
#endif
        } else if ([[s key] isEqualToString:@"CONC"]) { // concatenated
            [recordBody appendString:[s value]];
            [toRemove addObject:obj];
#ifdef BODY_CHANGED_PRINTFS
            bodyChanged = YES;
#endif
        }
        _value = [recordBody copy];
    }];
    
    [__elements removeObjectsInArray:toRemove];
    toRemove = nil;
    
    [__elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSGEDCOMStructure class]]) return;
        FSGEDCOMStructure * s = (FSGEDCOMStructure *)obj;
        NSString * __recordType = [s key];
        if (nil==[_elements objectForKey:__recordType]) [_elements setObject:[NSMutableArray array] forKey:__recordType];
        [[_elements objectForKey:__recordType] addObject:s];
    }];
    __elements = nil;
    
#ifdef BODY_CHANGED_PRINTFS
    if (bodyChanged) NSLog(@"%2lu: Record body changed for type %@ at %lu to body of: %@", level, _recordType, [buff globalOffsetOfByte:0], FSNSStringFromBytesAsASCII((voidPtr)[_recordBody UTF8String], strlen([_recordBody UTF8String])));
#endif
#ifdef BODY_CHANGED_PRINTFS
#undef BODY_CHANGED_PRINTFS
#endif
    
    [self postParse:dg];
} }

- (void)postParse:(FSGEDCOM *)dg { ; }

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * str = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [str fs_appendDictionaryStartWithIndentString:indent];
    [self addBasicElementsToDebugDescription:str locale:locale indentString:indent indentLevel:level];
    [str fs_appendDictionaryKey:@"_elements" value:_elements locale:locale indentString:indent indentLevel:level+1];
    [str fs_appendDictionaryEndWithIndentString:indent];
    
    return str;
}

- (void)addBasicElementsToDebugDescription:(NSMutableString *)s locale:(id)locale indentString:(NSString *)indentString indentLevel:(NSUInteger)level
{
    [s fs_appendDictionaryKey:@"_key" value:_key locale:locale indentString:indentString indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_value" value:_value locale:locale indentString:indentString indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_parsedOffset" value:[NSNumber numberWithUnsignedLongLong:_parsedOffset] locale:locale indentString:indentString indentLevel:level+1];
}

- (id)firstElementOfTypeAndRemoveKeyIfEmpty:(NSString *)key
{
    NSMutableArray * a = [_elements objectForKey:key];
    id obj = nil;
    if (0<[a count]) obj = [a objectAtIndex:0];
    if (1<[a count]) [a removeObjectAtIndex:0];
    else [_elements removeObjectForKey:key];
    return obj;
}

- (BOOL)hasMoreElements
{
    return 0<[[_elements allKeys] count];
}

#pragma mark - NSKeyValueCoding

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_elements objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [_elements setValue:value forKey:key];
}

#pragma mark - NSObject

+ (void)load
{
    @autoreleasepool {
        Class c0=[self class];
        if (c0!=[FSGEDCOMStructure class]) { // only respond to subclasses
            [[self registeredSubclasses] addObject:c0];
        }
    }
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.elements = [NSMutableDictionary dictionary];
    
    return self;
}

@end
