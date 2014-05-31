//
//  OCSquirrelClass.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"
#import "OCSquirrelObject.h"


#pragma mark - <OCSquirrelClass> protocol

@protocol OCSquirrelClass<NSObject, OCSquirrelObject>
@required

- (Class)nativeClass;

- (void)setClassAttributes:(id)attributes;
- (id)classAttributes;

- (void)pushNewInstance;

- (BOOL)bindInstanceMethodWithSelector:(SEL)selector
                                 error:(__autoreleasing NSError **)error;

@end


#pragma mark - OCSquirrelClass interface

@interface OCSquirrelClass : NSObject<OCSquirrelClass>

- (instancetype)initWithNativeClass:(Class)nativeClass
                               inVM:(OCSquirrelVM *)squirrelVM;

- (instancetype)initWithVM:(OCSquirrelVM *)squirrelVM;

@end
