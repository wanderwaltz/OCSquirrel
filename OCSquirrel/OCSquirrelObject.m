//
//  OCSquirrelObject.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelObject.h"


#pragma mark -
#pragma mark OCSquirrelObject implementation

@implementation OCSquirrelObject

#pragma mark -
#pragma mark properties

- (OCSquirrelVM *) squirrelVM
{
    if (_squirrelVM == nil)
    {
        @throw [NSException exceptionWithName: NSInternalInconsistencyException
                                       reason: @"*** OCSquirrelObject cannot function without "
                                               @"an OCSquirrelVM"
                                     userInfo: nil];
    }
    
    return _squirrelVM;
}


#pragma mark -
#pragma mark initializer methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super init];
    
    if (self != nil)
    {
        _squirrelVM = squirrelVM;
    }
    return self;
}

@end
