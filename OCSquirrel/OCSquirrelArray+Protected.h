//
//  OCSquirrelArray_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelArray.h"

@class OCSquirrelArrayImpl;

@interface OCSquirrelArray()
@property (nonatomic, strong, readonly) OCSquirrelArrayImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelArrayImpl *)impl;

@end
