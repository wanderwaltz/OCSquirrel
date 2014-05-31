//
//  OCSquirrelUserData_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 31.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelUserData.h"

@class OCSquirrelUserDataImpl;


#pragma mark -
#pragma mark OCSquirrelUserData private

@interface OCSquirrelUserData()
@property (nonatomic, strong, readonly) OCSquirrelUserDataImpl *impl;

- (instancetype)initWithImpl:(OCSquirrelUserDataImpl *)impl;

@end
