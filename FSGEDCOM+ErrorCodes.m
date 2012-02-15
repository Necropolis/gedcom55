//
//  FSGEDCOM+ErrorCodes.m
//  GEDCOM 5.5
//
//  Created by Christopher Miller on 1/20/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

const struct FSGEDCOMErrorCode FSGEDCOMErrorCode = {
    .UnsupportedEncoding = @"Unsupported Encoding",
    .UnknownEncoding = @"Unknown Encoding",
    .LongLine = @"Long Line",
    .MissingRequiredElement = @"Missing Required Element",
    .TooManyElements = @"Too Many Elements",
    .SpecificationBreach = @"Specification Breach",
    .TooManyPeople = @"Too Many People"
};
