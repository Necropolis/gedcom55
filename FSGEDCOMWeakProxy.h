//
//  FSGEDCOMWeakProxy.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/13/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

// very much pilfered from http://stackoverflow.com/a/3618797/622185
@interface FSGEDCOMWeakProxy : NSProxy {
@protected
    __weak id _object;
}

@property (readwrite, weak) id object;

+ (id)weakProxyWithObject:(id)object;
- (id)initWithObject:(id)object;

@end
