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

- (NSDictionary*)parseStructure:(ByteBuffer *)buff withLevel:(size_t)level
{ @autoreleasepool {
    _parsedOffset = [buff globalOffsetOfByte:0];
    NSRange r; ByteBuffer * recordPart; NSMutableArray * __elements = [[NSMutableArray alloc] init];
    
    r = [buff skipLine]; // skip line prevents infinite recursion
    
    // work with that thar line
    recordPart = [buff byteBufferWithRange:r];
    [recordPart scanUntilOneOfByteSequences:[ByteSequence whitespaceByteSequences]];
    _recordType = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[[ByteSequence newlineByteSequences] arrayByAddingObjectsFromArray:[ByteSequence whitespaceByteSequences]]] encoding:NSUTF8StringEncoding];
    _recordBody = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]] encoding:NSUTF8StringEncoding];
//    NSLog(@"%2lu %@@%lu %@", level, _recordType, _parsedOffset, FSNSStringFromBytesAsASCII((voidPtr)[_recordBody UTF8String], strlen([_recordBody UTF8String])));
    
    while ([buff hasMoreBytes]) {
        [buff skipNewlines];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:level+1]];
        recordPart = [buff byteBufferWithRange:r];
        Class c = [[self class] structureRespondingToByteBuffer:recordPart];
        FSGEDCOMStructure * s = [[c?:[FSGEDCOMStructure class] alloc] init];
        [s parseStructure:recordPart withLevel:level+1];
        recordPart->_cursor=0;
//        NSLog(@"%2lu: Found record bit of type %@ at %lu", level+1, [s recordType], [recordPart globalOffsetOfByte:0]);
        
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
    
    if (0==level)
        NSLog(@"%@", [self fs_descriptionDictionary]);
    
    return nil;
} }

- (NSString *)recordType { return _recordType; }

- (NSString *)recordBody { return _recordBody; }

#pragma mark - DescriptionDict

- (NSDictionary *)fs_descriptionDictionary
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (id _element in _elements) {
        if ([_element respondsToSelector:@selector(fs_descriptionDictionary)])
            [arr addObject:[_element fs_descriptionDictionary]];
        else
            [arr addObject:_element];
    }
    
    [dict setObject:[NSNumber numberWithUnsignedLongLong:_parsedOffset] forKey:@"_parsedOffset"];
    [dict setObject:_recordBody forKey:@"_recordBody"];
    [dict setObject:_recordType forKey:@"_recordType"];
    [dict setObject:arr forKey:@"_elements"];
    
    return dict;
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
