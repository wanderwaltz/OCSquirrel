//
//  OCSquirrelTable_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <OCSquirrel/OCSquirrel.h>
#import "OCSquirrelTableImpl.h"

@interface OCSquirrelTable ()
@property (nonatomic, strong) OCSquirrelTableImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelTableImpl *)impl;

@end
