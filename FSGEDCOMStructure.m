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
{
    NSRange r; ByteBuffer * recordPart;
    
    r = [buff skipLine]; // skip line prevents infinite recursion
    
    // work with that thar line
    recordPart = [buff byteBufferWithRange:r];
    [recordPart scanUntilOneOfByteSequences:[ByteSequence whitespaceByteSequences]];
    _recordType = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[[ByteSequence newlineByteSequences] arrayByAddingObjectsFromArray:[ByteSequence whitespaceByteSequences]]] encoding:NSUTF8StringEncoding];
    _recordBody = [recordPart stringFromRange:[recordPart scanUntilOneOfByteSequences:[ByteSequence newlineByteSequences]] encoding:NSUTF8StringEncoding];
    NSLog(@"%2lu %@@%lu %@", level, _recordType, [buff globalOffsetOfByte:0], FSNSStringFromBytesAsASCII((voidPtr)[_recordBody UTF8String], strlen([_recordBody UTF8String])));
    
    while ([buff hasMoreBytes]) {
        [buff skipNewlines];
        r = [buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:level+1]];
        recordPart = [buff byteBufferWithRange:r];
        Class c = [[self class] structureRespondingToByteBuffer:recordPart];
        FSGEDCOMStructure * s = [[c?:[FSGEDCOMStructure class] alloc] init];
        [s parseStructure:recordPart withLevel:level+1];
        recordPart->_cursor=0;
//        NSLog(@"%2lu: Found record bit of type %@ at %lu", level+1, [s recordType], [recordPart globalOffsetOfByte:0]);
        
        [_elements addObject:s];
    }
    
    __block BOOL bodyChanged = NO;
    [_elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSGEDCOMStructure class]]) return;
        FSGEDCOMStructure * s = (FSGEDCOMStructure *)obj;
        NSMutableString * recordBody = [[NSMutableString alloc] initWithString:_recordBody];
        if ([[s recordType] isEqualToString:@"CONT"]) { // continued
            [recordBody appendFormat:@"\n%@", [s recordBody]];
            bodyChanged = YES;
        } else if ([[s recordType] isEqualToString:@"CONC"]) { // concatenated
            [recordBody appendString:[s recordBody]];
            bodyChanged = YES;
        }
        _recordBody = [recordBody copy];
    }];
    
    if (bodyChanged) NSLog(@"%2lu: Record body changed for type %@ at %lu to body of: %@", level, _recordType, [buff globalOffsetOfByte:0], FSNSStringFromBytesAsASCII((voidPtr)[_recordBody UTF8String], strlen([_recordBody UTF8String])));
    
    return nil;
}

- (NSString *)recordType { return _recordType; }

- (NSString *)recordBody { return _recordBody; }

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
    
    self.elements = [NSMutableArray array];
    
    return self;
}

@end
