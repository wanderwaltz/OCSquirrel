//
//  OCSquirrelTableImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"
#import "OCSquirrelTable.h"


#pragma mark -
#pragma mark OCSquirrelTableImpl interface

@interface OCSquirrelTableImpl : OCSquirrelObjectImpl<OCSquirrelTable>

+ (id) rootTableForVM:     (OCSquirrelVM *) squirrelVM;
+ (id) registryTableForVM: (OCSquirrelVM *) squirrelVM;

@end


@interface OCSquirrelTableKeyEnumerator : NSEnumerator
- (instancetype)initWithTableImpl:(OCSquirrelTableImpl *)impl;
@end