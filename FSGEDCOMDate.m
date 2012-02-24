//
//  FSGEDCOMDate.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMDate.h"

#import "ByteBuffer.h"

#import "NSContainers+DebugPrint.h"

@implementation FSGEDCOMDate

@dynamic original;

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString * s = [[NSMutableString alloc] init];
    NSString * indent = [NSString fs_stringByFillingWithCharacter:' ' repeated:level*4];
    
    [s fs_appendDictionaryStartWithIndentString:indent];
    [s fs_appendDictionaryKey:@"_key" value:_key locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryKey:@"_value" value:_value locale:locale indentString:indent indentLevel:level+1];
    [s fs_appendDictionaryEndWithIndentString:indent];
    
    return s;
}

- (NSString *)original
{
    return self.value;
}

- (void)setOriginal:(NSString *)original
{
    [self willChangeValueForKey:@"original"];
    self.value = original;
    [self didChangeValueForKey:@"original"];
}

#pragma mark FSGEDCOMStructure

+ (BOOL)respondsTo:(ByteBuffer *)buff { return NO; }

+ (BOOL)respondsTo:(ByteBuffer *)buff parentObject:(FSGEDCOMStructure *)parent
{
    // cheating first
//    NSError * me = nil;
//    NSRegularExpression * regex = [[NSRegularExpression alloc] initWithPattern:@"\\A[0-9]+ DATE" options:0 error:&me];
//    size_t original_location = buff->_cursor;
//    NSRange firstLine = [buff skipLine];
//    NSString * _firstLine = [buff stringFromRange:firstLine encoding:NSUTF8StringEncoding];
//    NSUInteger matches = 
//    [regex numberOfMatchesInString:_firstLine options:0 range:NSMakeRange(0, [_firstLine length])];
//    buff->_cursor = original_location;
    
    size_t firstAlphanum=0;
    while (0==isalpha(((uint8 *)buff->_bytes)[firstAlphanum])&&firstAlphanum<buff->_length)
        ++firstAlphanum;
    if (firstAlphanum+4>buff->_length) return NO;
    else if (0==memcmp(&buff->_bytes[firstAlphanum], "DATE", 4)) return YES;
    else return NO;
}

- (void)postParse:(FSGEDCOM *)dg
{
    
}

#pragma mark NSObject

+ (void)load { [super load]; }

@end
