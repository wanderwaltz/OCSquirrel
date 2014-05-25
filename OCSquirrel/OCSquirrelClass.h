//
//  OCSquirrelClass.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTableImpl.h"

// TODO: chained invocations

#pragma mark -
#pragma mark OCSquirrelClass interface

@interface OCSquirrelClass : OCSquirrelTableImpl
@property (readonly, nonatomic) Class nativeClass;

- (void) setClassAttributes: (id) attributes;
- (id) classAttributes;


- (void) pushNewInstance;

- (BOOL) bindInstanceMethodWithSelector: (SEL) selector
                                  error: (__autoreleasing NSError **) error;

/*! Uses Objective-C runtime functions to iterate through all methods of the corresponding
    native class and bind them to the Squirrel class. This is potentially dangerous operation
    since this also makes 'private', i.e. not usually visible methods accessible and is
    generally resource consuming especially if `includeSuperclasses` is set to YES (for example
    traversing the NSObject's list of methods gives us 120 methods to bind).
 
    Use with caution. It is generally safer to bind only several needed methods using 
    -bindInstanceMethodWithSelector:error:
 */
- (BOOL) bindAllInstanceMethodsIncludingSuperclasses: (BOOL) includeSuperclasses
                                               error: (__autoreleasing NSError **) error;

@end
