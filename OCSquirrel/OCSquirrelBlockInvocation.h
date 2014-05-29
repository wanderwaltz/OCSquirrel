//
//  OCSquirrelBlockInvocation.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark - NSInvocation+OCSquirrelBlockInvocation implementation

@interface NSInvocation (OCSquirrelBlockInvocation)

+ (instancetype)squirrelBlockInvocationWithBlock:(id)block;

@end
