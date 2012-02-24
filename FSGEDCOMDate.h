//
//  FSGEDCOMDate.h
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOMStructure.h"

@interface FSGEDCOMDate : FSGEDCOMStructure

/**
 * What was originally in the GEDCOM file? This will always be the un-changed string of the date as read (parsing will not alter this).
 */
@property (readwrite) NSString * original;

@end
