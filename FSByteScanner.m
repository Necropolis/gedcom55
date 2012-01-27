//
//  FSByteScanner.c
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/19/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#include "FSByteScanner.h"

NSString* FSNSStringFromBytes(const voidPtr bytes, size_t len)
{
    if (0==len) return @"";
    NSMutableString* str = [NSMutableString stringWithCapacity:3*len];
    for (size_t i=0;
         i < len;
         ++i)
        [str appendFormat:@"%02hhx ", ((uint8*)bytes)[i]];
    [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
    return str;
}

NSString* FSNSStringFromBytesAsASCII(const voidPtr bytes, size_t len)
{
    if (0==len) return @"";
    NSMutableString* str = [NSMutableString stringWithCapacity:3*len]; // guesstimate
    for (size_t i=0;
         i < len;
         ++i) {
        uint8 c = ((uint8*)bytes)[i];
        if (isgraph(c))      [str appendFormat:@" %c ",    c];
        else if (isspace(c)) {
            if (c=='\r')     [str appendString:@"\\r "      ];
            else if (c=='\n')[str appendString:@"\\n "      ];
            else if (c=='\v')[str appendString:@"\\v "      ];
            else if (c=='\f')[str appendString:@"\\f "      ];
            else if (c=='\t')[str appendString:@"\\t "      ];
            else if (c==' ' )[str appendString:@"sp "       ]; 
            else             [str appendFormat:@"%02hhx ", c];
        }
        else                 [str appendFormat:@"%02hhx ", c];
    }
    [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
    return str;
}
