//
//  FSGEDCOMHead.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSGEDCOMStructure.h"

@class FSGEDCOMCharset;

@interface FSGEDCOMHead : FSGEDCOMStructure {
    FSGEDCOMCharset * _charset;
}

@property (readwrite, strong) FSGEDCOMCharset * charset;

@end

@interface FSGEDCOMCharset : FSGEDCOMStructure
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
