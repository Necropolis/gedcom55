//
// FSGEDCOM.m
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"
#import "FSGEDCOM+ParserInternal.h"

#import "FSGEDCOMStructure.h"
#import "FSGEDCOMFamily.h"
#import "FSGEDCOMIndividual.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

#import "NSContainers+DebugPrint.h"

@interface FSGEDCOM ()

@property (readwrite, strong) NSMutableDictionary * familyCallbacks;
@property (readwrite, strong) NSMutableDictionary * individualCallbacks;

- (FSGEDCOMStructure*)parseStructure:(ByteBuffer *)buff;

@end

@implementation FSGEDCOM {
    NSMutableDictionary * _warnings;
    NSMutableDictionary * _familyCallbacks;
    NSMutableDictionary * _individualCallbacks;
}

@synthesize structures=_structures;
@synthesize individuals=_individuals;
@synthesize families=_families;

@synthesize familyCallbacks=_familyCallbacks;
@synthesize individualCallbacks=_individualCallbacks;

- (NSDictionary*)parse:(NSData*)data
{
    NSError * error;
    [NSObject fs_swizzleContainerPrinters:&error];
    if (error) NSLog(@"Failed to swizzle stuff for pretty printing");
    
    ByteBuffer* _buff = [[ByteBuffer alloc] initWithBytes:(const voidPtr)[data bytes] cursor:0 length:[data length] copy:YES];
        
    uint8 ansel_or_ascii[] = { 0x30, 0x20       }; BOOL is_ansel_or_ascii = 0==memcmp(_buff.bytes, ansel_or_ascii, 2);
    uint8 utf8[]           = { 0xEF, 0xBB, 0xBF }; BOOL is_utf8           = 0==memcmp(_buff.bytes, utf8,           3);
    uint8 unicode1[]       = { 0x30, 0x00       }; BOOL is_unicode1       = 0==memcmp(_buff.bytes, unicode1,       2);
    uint8 unicode2[]       = { 0x00, 0x30       }; BOOL is_unicode2       = 0==memcmp(_buff.bytes, unicode2,       2);
    
    if (is_ansel_or_ascii) {
        [self addWarning:@"I don't support any encoding other than UTF-8" ofType:FSGEDCOMErrorCode.UnsupportedEncoding];
        return _warnings;
    } else if (!is_unicode1 && !is_unicode2 && !is_utf8) { // not fatal, however the behavior is undefined.
        [self addWarning:@"Data lacks a header byte pattern for Unicode support (per pg. 63-64 of GEDCOM 5.5 spec). If this isn't Unicode, then the behavior of the parse is undefined and the program may crash." ofType:FSGEDCOMErrorCode.UnknownEncoding];
    }
    
    if (is_utf8) _buff.cursor += 3;
    else if (is_unicode1||is_unicode2) _buff.cursor += 2;
    
    NSRange r; ByteBuffer * _subbuffer;
    while ([_buff hasMoreBytes]) {
        r = [_buff scanUntilOneOfByteSequences:[ByteSequence newlineByteSequencesWithIntegerPrefix:0]];
        _subbuffer = [_buff byteBufferWithRange:r];
        [_buff skipNewlines];
        FSGEDCOMStructure * structure = [self parseStructure:_subbuffer];
        if (structure==nil) {
            [self addWarning:[NSString stringWithFormat:@"Found an unparseable record at offset 0x%08qX", r.location] ofType:@"unknownRecords"];
        }
        
        [_structures addObject:structure];
        
    }
    
    // pull out individuals and families; put them into their arrays
    
    NSMutableArray * toRemove = [[NSMutableArray alloc] init];
    [self.structures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[FSGEDCOMIndividual class]]||[obj isKindOfClass:[FSGEDCOMFamily class]]) {
            [toRemove addObject:obj];
        }
    }];
    [_structures removeObjectsInArray:toRemove];
    toRemove = nil;
    NSArray * arr = [_familyCallbacks allKeys];
    if (0<[arr count])
        [self addWarning:[NSString stringWithFormat:@"References to families (%@) found, but they were never ever defined!", [arr componentsJoinedByString:@","]] ofType:@"Missing Families"];
    arr = [_individualCallbacks allKeys];
    if (0<[arr count])
        [self addWarning:[NSString stringWithFormat:@"References to individuals (%@) found, but they were never ever defined!", [arr componentsJoinedByString:@","]] ofType:@"Missing Persons"];
    self.familyCallbacks = nil; // clean up parser nonsense
    self.individualCallbacks = nil;
    
    return _warnings;
}

- (void)addWarning:(NSString *)warning ofType:(NSString *)type
{
    if (nil==[_warnings objectForKey:type]) [_warnings setObject:[NSMutableArray array] forKey:type];
    [[_warnings objectForKey:type] addObject:warning];
}

- (void)registerFamily:(FSGEDCOMFamily *)family
{
    [self.families setObject:family forKey:family.value];
    NSMutableArray * callbacks = [self.familyCallbacks objectForKey:family.value];
    if (!callbacks) return;
    for (FSGEDCOMFamilyCallback callback in callbacks) callback(family);
    [self.familyCallbacks removeObjectForKey:family.value];
}

- (void)registerCallback:(FSGEDCOMFamilyCallback)callback forFamily:(NSString *)family
{
    FSGEDCOMFamily * _family = [self.families objectForKey:family];
    if (_family) { callback(_family); return; }
    if (![self.familyCallbacks objectForKey:family]) [self.familyCallbacks setObject:[NSMutableArray array] forKey:family];
    [[self.familyCallbacks objectForKey:family] addObject:[callback copy]];
}

- (void)registerIndividual:(FSGEDCOMIndividual *)individual
{
    [self.individuals setObject:individual forKey:individual.value];
    NSMutableArray * callbacks = [self.individualCallbacks objectForKey:individual.value];
    if (!callbacks) return;
    for (FSGEDCOMIndividualCallback callback in callbacks) callback(individual);
    [self.individualCallbacks removeObjectForKey:individual.value];
}

- (void)registerCallback:(FSGEDCOMIndividualCallback)callback forIndividual:(NSString *)individual
{
    FSGEDCOMIndividual * _individual = [self.individuals objectForKey:individual];
    if (_individual) { callback(_individual); return; }
    if (![self.individualCallbacks objectForKey:individual]) [self.individualCallbacks setObject:[NSMutableArray array] forKey:individual];
    [[self.individualCallbacks objectForKey:individual] addObject:[callback copy]];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * str = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    // kill the _EVDEF's coz they're freaking stupid
    NSArray * arr = [_structures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key != \"_EVDEF\""]];
    
    [str fs_appendDictionaryStartWithIndentString:indent];
    [str fs_appendDictionaryKey:@"records" value:arr locale:locale indentString:indent indentLevel:level+1];
    [str fs_appendDictionaryKey:@"individuals" value:_individuals locale:locale indentString:indent indentLevel:level+1];
    [str fs_appendDictionaryKey:@"families" value:_families locale:locale indentString:indent indentLevel:level+1];
    [str fs_appendDictionaryKey:@"parseWarnings" value:_warnings locale:locale indentString:indent indentLevel:level+1];
    [str fs_appendDictionaryEndWithIndentString:indent];
    
    return str;
}

#pragma mark Parser Common

- (FSGEDCOMStructure*)parseStructure:(ByteBuffer *)buff
{
    Class c = [FSGEDCOMStructure structureRespondingToByteBuffer:buff];
    FSGEDCOMStructure * s = nil;
    if (c) s = [[c alloc] init];
    else s = [[FSGEDCOMStructure alloc] init];
    [s parseStructure:buff withLevel:0 delegate:self];
    return s;
}

#pragma mark NSObject

- (id)init {
    self = [super init];
    if (!self) return nil;

    _structures = [[NSMutableArray alloc] init];
    _warnings = [[NSMutableDictionary alloc] init];
    _families = [[NSMutableDictionary alloc] init];
    _familyCallbacks = [[NSMutableDictionary alloc] init];
    _individuals = [[NSMutableDictionary alloc] init];
    _individualCallbacks = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

@end
