//
//  OCSquirrelClosureImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"


#pragma mark -
#pragma mark OCSquirrelClosureImpl interface

@interface OCSquirrelClosureImpl : OCSquirrelObjectImpl

- (id)initWithSQFUNCTION:(SQFUNCTION)function
              squirrelVM:(OCSquirrelVM *)squirrelVM;

- (id)initWithSQFUNCTION:(SQFUNCTION)function
                    name:(NSString *)name
              squirrelVM:(OCSquirrelVM *)squirrelVM;


- (id)call;
- (id)call:(NSArray *)parameters;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject
        parameters:(NSArray *)parameters;

@end
