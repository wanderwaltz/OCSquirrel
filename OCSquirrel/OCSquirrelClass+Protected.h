//
//  OCSquirrelClass_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelClass.h"

@class OCSquirrelClassImpl;


#pragma mark - OCSquirrelClass private

@interface OCSquirrelClass()
@property (nonatomic, strong, readonly) OCSquirrelClassImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelClassImpl *)impl;

@end
