//
//  OCSquirrelTable_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTable.h"

@class OCSquirrelTableImpl;

@interface OCSquirrelTable()
@property (nonatomic, strong, readonly) OCSquirrelTableImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelTableImpl *)impl;

@end
