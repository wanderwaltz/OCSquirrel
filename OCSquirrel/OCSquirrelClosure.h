//
//  OCSquirrelClosure.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"
#import "OCSquirrelObject.h"


#pragma mark - <OCSquirrelClosure> protocol

@protocol OCSquirrelClosure<NSObject, OCSquirrelObject>
@required

- (id)call;
- (id)call:(NSArray *)parameters;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject;

- (id)callWithThis:(id<OCSquirrelObject>)thisObject
        parameters:(NSArray *)parameters;

@end


#pragma mark - OCSquirrelClosure interface

@interface OCSquirrelClosure : NSObject<OCSquirrelClosure>

- (instancetype)initWithSQFUNCTION:(SQFUNCTION)function
                        squirrelVM:(OCSquirrelVM *)squirrelVM;

- (instancetype)initWithSQFUNCTION:(SQFUNCTION)function
                              name:(NSString *)name
                        squirrelVM:(OCSquirrelVM *)squirrelVM;

@end
