//
//  OCSquirrelClosure_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelClosure.h"

@class OCSquirrelClosureImpl;

@interface OCSquirrelClosure()
@property (nonatomic, strong, readonly) OCSquirrelClosureImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelClosureImpl *)impl;

@end
