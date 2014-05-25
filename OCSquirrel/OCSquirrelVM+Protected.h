//
//  OCSquirrelVM_Protected.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrel.h"
#import "OCSquirrelVMStackImpl.h"


#pragma mark -
#pragma mark OCSquirrelVM class extension

@interface OCSquirrelVM ()
{
@protected
    /// A concrete implementation of the stack property
    OCSquirrelVMStackImpl *_stack;
    
    /// Contains Objective-C class names as keys an OCSquirrelClass instances as values
    NSMutableDictionary *_classBindings;
}

@property (nonatomic, readonly) HSQUIRRELVM vm;

@property (strong, readwrite, nonatomic) NSError *lastError;
@property (readonly, nonatomic) NSDictionary *classBindings;

@end
