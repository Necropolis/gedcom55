//
//  FSGEDCOMFamily.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/13/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMStructure.h"

@class FSGEDCOMIndividual;

@interface FSGEDCOMFamily : FSGEDCOMStructure {
@protected
    __weak FSGEDCOMIndividual * _husband;
    __weak FSGEDCOMIndividual * _wife;
    NSMutableArray * _children;
}

@property (readwrite, weak) FSGEDCOMIndividual * husband;
@property (readwrite, weak) FSGEDCOMIndividual * wife;
@property (readwrite, strong) NSMutableArray * children;

@end
