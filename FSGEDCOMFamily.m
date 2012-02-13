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

#import "ByteBuffer.h"
#import "ByteSequence.h"

@implementation FSGEDCOMFamily

@synthesize husband=_husband;
@synthesize wife=_wife;
@synthesize children=_children;

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
        if (1<[arr count]) [dg addWarning:@"Too many husbands in this family! Poligamy much?" ofType:@"Too Many People"];
        _rec = [arr objectAtIndex:0];
        if (_rec) {
            tmp = _rec.value;
            _rec.value = [_rec.key stringByTrimmingCharactersInSet:atSign];
            _rec.key = tmp;
            [dg registerCallback:^(FSGEDCOMIndividual * husband) { self.husband = husband; } forIndividual:_rec.value]; // actually some pretty spiffy functional programming
        }
    }
    arr = [self.elements objectForKey:@"WIFE"];
    if (arr) {
        if (1<[arr count]) [dg addWarning:@"Too many wives in this family! Poligamy much?" ofType:@"Too Many People"];
        _rec = [arr objectAtIndex:0];
        if (_rec) {
            tmp = _rec.value;
            _rec.value = [_rec.key stringByTrimmingCharactersInSet:atSign];
            _rec.key = tmp;
            [dg registerCallback:^(FSGEDCOMIndividual * wife) { self.wife = wife; } forIndividual:_rec.value];
        }
    }
    arr = [self.elements objectForKey:@"CHIL"]; // freakin children
    if (arr) {
        self.children = [[NSMutableArray alloc] initWithCapacity:[arr count]];
        for (NSUInteger i = 0;
             i < [arr count];
             ++i) { // fill in children with nulls so that replace-object can honor the order in which they appear in the GEDCOM file.
            [self.children addObject:[NSNull null]];
        }
        for (NSUInteger i = 0;
             i < [arr count];
             ++i) {
            _rec = [arr objectAtIndex:i];
            tmp = _rec.value;
            _rec.value = [_rec.key stringByTrimmingCharactersInSet:atSign];
            _rec.key = tmp;
            [dg registerCallback:^(FSGEDCOMIndividual * child) { [self.children replaceObjectAtIndex:i withObject:child]; } forIndividual:_rec.value];
        }
    }
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end
