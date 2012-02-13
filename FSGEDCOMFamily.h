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
    FSGEDCOMIndividual * _husband;
    FSGEDCOMIndividual * _wife;
    NSMutableArray * _children;
}

@property (readwrite, strong) FSGEDCOMIndividual * husband;
@property (readwrite, strong) FSGEDCOMIndividual * wife;
@property (readwrite, strong) NSMutableArray * children;

@end
