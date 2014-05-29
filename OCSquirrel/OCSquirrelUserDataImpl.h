//
//  OCSquirrelUserDataImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"

@interface OCSquirrelUserDataImpl : OCSquirrelObjectImpl
@property (nonatomic, strong, readonly) id object;

- (instancetype)initWithObject:(id)object
                          inVM:(OCSquirrelVM *)squirrelVM;

@end
