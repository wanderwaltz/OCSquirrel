//
//  OCSquirrelUserDataImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"
#import "OCSquirrelUserData.h"

@interface OCSquirrelUserDataImpl : OCSquirrelObjectImpl<OCSquirrelUserData>
@property (nonatomic, strong, readonly) id object;

- (instancetype)initWithObject:(id)object
                          inVM:(OCSquirrelVM *)squirrelVM;

@end
