//
//  FSGEDCOM+ParserInternal.h
//  fs-dataman
//
//  Created by Christopher Miller on 2/13/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSGEDCOM.h"

typedef void(^FSGEDCOMFamilyCallback)(FSGEDCOMFamily *);
typedef void(^FSGEDCOMIndividualCallback)(FSGEDCOMIndividual *);

@interface FSGEDCOM (ParserInternal)

@property (readwrite, strong) NSMutableDictionary * familyCallbacks;
@property (readwrite, strong) NSMutableDictionary * individualCallbacks;

- (void)addWarning:(NSString *)warning ofType:(NSString *)type;
- (void)registerFamily:(FSGEDCOMFamily *)family;
- (void)registerCallback:(FSGEDCOMFamilyCallback)callback forFamily:(NSString *)family;
- (void)registerIndividual:(FSGEDCOMIndividual *)individual;
- (void)registerCallback:(FSGEDCOMIndividualCallback)callback forIndividual:(NSString *)individual;

@end
