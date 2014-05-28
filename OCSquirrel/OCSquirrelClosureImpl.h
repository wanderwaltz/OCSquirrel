//
//  OCSquirrelClosureImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"
#import "OCSquirrelClosure.h"


#pragma mark -
#pragma mark OCSquirrelClosureImpl interface

@interface OCSquirrelClosureImpl : OCSquirrelObjectImpl<OCSquirrelClosure>

- (id)initWithSQFUNCTION:(SQFUNCTION)function
              squirrelVM:(OCSquirrelVM *)squirrelVM;

- (id)initWithSQFUNCTION:(SQFUNCTION)function
                    name:(NSString *)name
              squirrelVM:(OCSquirrelVM *)squirrelVM;

- (instancetype)initWithBlock:(id)block
                   squirrelVM:(OCSquirrelVM *)squirrelVM;

- (instancetype)initWithBlock:(id)block
                         name:(NSString *)name
                   squirrelVM:(OCSquirrelVM *)squirrelVM;



- (id)call;
- (id)call:(NSArray *)parameters;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject
        parameters:(NSArray *)parameters;

@end
