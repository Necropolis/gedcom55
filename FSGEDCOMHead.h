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
@class FSGEDCOMFile;
@class FSGEDCOMDestination;

@interface FSGEDCOMHead : FSGEDCOMStructure {
    FSGEDCOMCharset * _charset;
    FSGEDCOMFile * _file;
    FSGEDCOMDestination * _destination;
}

@property (readwrite, strong) FSGEDCOMCharset * charset;
@property (readwrite, strong) FSGEDCOMFile * file;
@property (readwrite, strong) FSGEDCOMDestination * destination;

@end

@interface FSGEDCOMCharset : FSGEDCOMStructure
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMFile : FSGEDCOMStructure
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMDestination : FSGEDCOMStructure
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end