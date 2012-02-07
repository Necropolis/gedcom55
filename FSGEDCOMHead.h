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
@class FSGEDCOMCharset;
@class FSGEDCOMCharsetVersion;
@class FSGEDCOMFile;
@class FSGEDCOMDestination;

@interface FSGEDCOMHead : FSGEDCOMStructure {
    FSGEDCOMHeaderSource * _source;
    FSGEDCOMCharset * _charset;
    FSGEDCOMFile * _file;
    FSGEDCOMDestination * _destination;
}

@property (readwrite, strong) FSGEDCOMHeaderSource * source;
@property (readwrite, strong) FSGEDCOMCharset * charset;
@property (readwrite, strong) FSGEDCOMFile * file;
@property (readwrite, strong) FSGEDCOMDestination * destination;

@end

@interface FSGEDCOMHeaderSource : FSGEDCOMStructure {

}
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMHeaderSourceName : FSGEDCOMStructure
@end
@interface FSGEDCOMCharset : FSGEDCOMStructure {
    FSGEDCOMCharsetVersion * _charsetVersion;
}
@property (readwrite, strong) FSGEDCOMCharsetVersion * charsetVersion;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface FSGEDCOMCharsetVersion : FSGEDCOMStructure
@end
@interface FSGEDCOMFile : FSGEDCOMStructure
@end
@interface FSGEDCOMDestination : FSGEDCOMStructure
@end