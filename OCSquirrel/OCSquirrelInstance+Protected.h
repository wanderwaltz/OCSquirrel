//
//  OCSquirrelInstance_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelInstance.h"

@class OCSquirrelInstanceImpl;


#pragma mark - OCSquirrelInstance private

@interface OCSquirrelInstance()
@property (nonatomic, strong, readonly) OCSquirrelInstanceImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelInstanceImpl *)impl;

@end
