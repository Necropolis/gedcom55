//
//  FSGEDCOMHead.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSGEDCOMStructure.h"

@class FSGEDCOMHeaderSource;
@class FSGEDCOMHeaderGEDCOM;
@class FSGEDCOMHeaderCharset;
@class FSGEDCOMHeaderCharsetVersion;

@interface FSGEDCOMHead : FSGEDCOMStructure {
    FSGEDCOMHeaderSource * _source;
    FSGEDCOMHeaderGEDCOM * _gedcom;
    FSGEDCOMHeaderCharset * _charset;
    NSString * _file;
    NSString * _destination;
}

@property (readwrite, strong) FSGEDCOMHeaderSource * source;
@property (readwrite, strong) FSGEDCOMHeaderGEDCOM * gedcom;
@property (readwrite, strong) FSGEDCOMHeaderCharset * charset;
@property (readwrite, strong) NSString * file;
@property (readwrite, strong) NSString * destination;

@end

@interface FSGEDCOMHeaderSource : FSGEDCOMStructure {
    NSString * _name;
    NSString * _version;
}
@property (readwrite, strong) NSString * name;
@property (readwrite, strong) NSString * version;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMHeaderSourceVersion : FSGEDCOMStructure
@end
@interface FSGEDCOMHeaderGEDCOM : FSGEDCOMStructure {
    NSString * _version;
    NSString * _form;
}
@property (readwrite, strong) NSString * version;
@property (readwrite, strong) NSString * form;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMHeaderCharset : FSGEDCOMStructure {
    FSGEDCOMHeaderCharsetVersion * _charsetVersion;
}
@property (readwrite, strong) FSGEDCOMHeaderCharsetVersion * charsetVersion;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMHeaderCharsetVersion : FSGEDCOMStructure
@end
