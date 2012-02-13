//
//  FSGEDCOMIndividual.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/3/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMStructure.h"

@interface FSGEDCOMIndividual : FSGEDCOMStructure {
    NSMutableArray * _familiesWhereChild;
    NSMutableArray * _familiesWhereSpouse;
}

@property (readwrite, strong) NSMutableArray * familiesWhereChild;
@property (readwrite, strong) NSMutableArray * familiesWhereSpouse;

@end
