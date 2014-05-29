//
//  OCSquirrelBlockInvocationMetadata.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelBlockInvocationMetadata.h"
#import <objc/runtime.h>

@implementation OCSquirrelBlockInvocationMetadata

- (instancetype)initWithBlock:(id)block
                          imp:(IMP)blockImp
{
    self = [super init];
    
    if (self != nil) {
        _block = [block copy];
        _blockImp = blockImp;
    }
    
    return self;
}


- (void)dealloc
{
    imp_removeBlock(_blockImp);
    _blockImp = NULL;
}

@end
