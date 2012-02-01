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

@implementation FSGEDCOMStructure {
    NSString* _recordType;
    NSString* _recordBody;
    size_t _parsedOffset;
}

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
    for (Class c in [FSGEDCOMStructure registeredSubclasses]) {
        if ([c respondsTo:buff]) {
            return c;
        }
    }
    return nil;
}

+ (BOOL)respondsTo:(ByteBuffer *)buff
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
    size_t l = [[recordPart stringFromRange:NSMakeRange(0, recordPart->_length) encoding:NSUTF8StringEncoding] length];
    if (l>=kMaxLineLength) {
        [dg addWarning:[NSString stringWithFormat:@"Found a line of length %lu which is longer than %lu beginning at offset %lu", l, kMaxLineLength, [recordPart globalOffsetOfByte:0]] ofType:kLongLines];
    }
    _recordType = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[[ByteSequence newlineByteSequences] arrayByAddingObjectsFromArray:[ByteSequence whitespaceByteSequences]]] encoding:NSUTF8StringEncoding];
    _recordBody = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]] encoding:NSUTF8StringEncoding];
    
    while ([buff hasMoreBytes]) {
        [buff skipNewlines];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:level+1]];
        recordPart = [buff byteBufferWithRange:r];
        Class c = [[self class] structureRespondingToByteBuffer:recordPart];
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
        NSMutableString * recordBody = [[NSMutableString alloc] initWithString:_recordBody];
        if ([[s recordType] isEqualToString:@"CONT"]) { // continued
            [recordBody appendFormat:@"\n%@", [s recordBody]];
            [toRemove addObject:obj];
#ifdef BODY_CHANGED_PRINTFS
            bodyChanged = YES;
#endif
        } else if ([[s recordType] isEqualToString:@"CONC"]) { // concatenated
            [recordBody appendString:[s recordBody]];
            [toRemove addObject:obj];
#ifdef BODY_CHANGED_PRINTFS
            bodyChanged = YES;
#endif
        }
        _recordBody = [recordBody copy];
    }];
    
    [__elements removeObjectsInArray:toRemove];
    toRemove = nil;
    
    [__elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSGEDCOMStructure class]]) return;
        FSGEDCOMStructure * s = (FSGEDCOMStructure *)obj;
        NSString * __recordType = [s recordType];
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
    
    ;
} }

- (void)postParse:(FSGEDCOM *)dg { ; }

- (NSString *)recordType { return _recordType; }

- (NSString *)recordBody { return _recordBody; }

#pragma mark - DescriptionDict

- (NSDictionary *)fs_descriptionDictionary
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[NSNumber numberWithUnsignedLongLong:_parsedOffset] forKey:@"_parsedOffset"];
    [dict setObject:_recordBody forKey:@"_recordBody"];
    [dict setObject:_recordType forKey:@"_recordType"];
    [dict setObject:_elements forKey:@"_elements"];
    
    return dict;
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
