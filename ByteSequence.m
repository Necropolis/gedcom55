//
//  ByteSequence.m
//  fs-dataman
//
//  Created by Christopher Miller on 1/26/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "ByteSequence.h"

#import "BytePrinting.h"

@implementation ByteSequence

@synthesize bytes=_bytes;
@synthesize length=_length;

+ (id)newlineByteSequencesWithIntegerPrefix:(size_t)pfx
{
    static NSMutableArray * a;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        a = [[NSMutableArray alloc] init];
    });
    if (pfx+1>[a count]) {
        // make a new ones
        for (NSUInteger i=[a count];
             i < pfx+1;
             ++i) {
            size_t l = [[NSString stringWithFormat:@"%lu", i] length];
            voidPtr p = malloc(sizeof(char)*(3+l));
            NSMutableArray* at = [NSMutableArray arrayWithCapacity:3];
            sprintf(p, "\r\n%lu", i); [at addObject:[[ByteSequence alloc] initWithBytes:p length:2+l]];
            sprintf(p, "\n\r%lu", i); [at addObject:[[ByteSequence alloc] initWithBytes:p length:2+l]];
            sprintf(p, "\n%lu", i);   [at addObject:[[ByteSequence alloc] initWithBytes:p length:1+l]];
            sprintf(p, "\r%lu", i);   [at addObject:[[ByteSequence alloc] initWithBytes:p length:1+l]];
            [a addObject:[at copy]];
            free(p);
        }
    }
    return [a objectAtIndex:pfx];
}

+ (id)newlineByteSequences
{
    static NSArray * a;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        a = [[NSArray alloc] initWithObjects:
             [[ByteSequence alloc] initWithBytes:"\r\n" length:2],
             [[ByteSequence alloc] initWithBytes:"\n\r" length:2],
             [[ByteSequence alloc] initWithBytes:"\n"   length:1],
             [[ByteSequence alloc] initWithBytes:"\r"   length:1], nil];
    });
    return a;
}

+ (id)whitespaceByteSequences
{
    static NSArray * a;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        a = [[NSArray alloc] initWithObjects:
             [[ByteSequence alloc] initWithBytes:" " length:1],
             [[ByteSequence alloc] initWithBytes:"\t" length:1], nil];
    });
    return a;
}

- (id)initWithBytes:(const voidPtr)bytes length:(size_t)length
{
    self = [super init];
    if (!self) return nil;
    
    _bytes = malloc(sizeof(void)*length);
    memcpy(_bytes, bytes, length);
    self.length = length;
    
    return self;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
//- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSString* __indent = level==0?@"    ":@"\t";
    return [NSString stringWithFormat:@"{\n%@    length: %lu,\n%@    bytes: %@\n%@    ASCII: %@\n%@}",
            __indent,
            _length,
            __indent,
            FSNSStringFromBytes(_bytes, _length),
            __indent,
            FSNSStringFromBytesAsASCII(_bytes, _length),
            __indent];
}

- (NSString *)description
{    
    return [self descriptionWithLocale:nil indent:0];
}

- (void)dealloc
{
    free(_bytes);
}

@end
