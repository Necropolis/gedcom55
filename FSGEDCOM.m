//
// FSGEDCOM.m
// GEDCOM 5.5
//
//  Created by Christopher Miller on 1/18/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

#import "FSGEDCOMStructure.h"

#import "ByteBuffer.h"
#import "ByteSequence.h"

#import "NSContainers+DebugPrint.h"

@interface FSGEDCOM (__parser_common__)

+ (NSArray*)allStructureClasses;

- (FSGEDCOMStructure*)parseStructure:(ByteBuffer *)buff;

@end

@implementation FSGEDCOM {
    NSMutableDictionary * _warnings;
}

@synthesize structures=_structures;

- (NSDictionary*)parse:(NSData*)data
{
    NSError * error;
    [NSObject fs_swizzleContainerPrinters:&error];
    if (error) return nil;
    // TODO: Scan through the GEDCOM, line by line!
    // Use FSByteScanner to do this!
    
    // GEDCOM 5.5 defines an encoding type of Unicode (probably UTF-8), but older files may use ANSEL
    
    // Current battle plan:
    // Scan through, byte by byte! The plumbing that defines the structure is all ASCII, so that'll
    // live on 8-bit boundaries. The user-input data may not, however.
    // There are multi-line strings in GEDCOM 5.5, so these will need to be reconstructed at the byte-
    // level. Particularly, I'm not confident that Foundation will be able to reconstruct split
    // graphemes with reasonable success, so that level of data-smashing will probably be done in C
    // and then the combined void* region will be passed through to NSString.
    
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
    
    return _warnings;
}

- (void)addWarning:(NSString *)warning ofType:(NSString *)type
{
    if (nil==[_warnings objectForKey:type]) [_warnings setObject:[NSMutableArray array] forKey:type];
    [[_warnings objectForKey:type] addObject:warning];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * str = [[NSMutableString alloc] init];
    char * indent = malloc(sizeof(char)*4*level+1);
    memset(indent, ' ', sizeof(char)*4*level);
    indent[4*level]='\0';
    
    [str appendFormat:@"%s{\n",indent];
    [str appendFormat:@"%s    records = %@;\n",indent,[_structures descriptionWithLocale:locale indent:level+1]];
    [str appendFormat:@"%s    parseWarnings = %@;\n",indent,[_warnings descriptionWithLocale:locale indent:level+1]];
    [str appendFormat:@"%s}",indent];
    
    free(indent);
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
    
    return self;
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

@end
