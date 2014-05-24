//
//  OCSquirrelClass.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClass.h"
#import "OCSquirrelClosure.h"
#import "OCSquirrelVMBindings_NoARC.h"

#import <objc/runtime.h>

#pragma mark -
#pragma mark OCSquirrelClass implementation

@implementation OCSquirrelClass

#pragma mark -
#pragma mark properties

- (Class) nativeClass
{
    Class class   = nil;
    id attributes = [self classAttributes];
    
    if ([attributes isKindOfClass: [NSValue class]])
    {
        class = (__bridge Class)[attributes pointerValue];
    }
    
    return class;
}


#pragma mark -
#pragma mark class methods

+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type
{
    return (type == OT_CLASS);
}


#pragma mark -
#pragma mark initialization methods

- (id) initWithVM: (OCSquirrelVM *) squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM doWaitPreservingStackTop: ^{
            sq_newclass(squirrelVM.vm, SQFalse);
            sq_getstackobj(squirrelVM.vm, -1, &_obj);
            sq_addref(squirrelVM.vm, &_obj);
        }];
    }
    return self;
}


#pragma mark -
#pragma mark bindings

- (BOOL) bindInstanceMethodWithSelector: (SEL) selector
                                  error: (__autoreleasing NSError **) error
{
    BOOL success = YES;
    Class nativeClass = self.nativeClass;
    
    if (nativeClass != nil)
    {
        if ([nativeClass instancesRespondToSelector: selector])
        {
            [self.squirrelVM doWaitPreservingStackTop: ^{
                NSString *selectorString = NSStringFromSelector(selector);
                
                // Exclude initializer methods from the search for now
                if (selectorString != nil)
                {
                    NSArray *components = [selectorString componentsSeparatedByString: @":"];
                    
                    // Simple invocation without parameters or with a single parameter
                    if (components.count <= 2)
                    {
                        SQFUNCTION nativeFunction = NULL;
                        
                        if ([selectorString rangeOfString: @"init"].location != 0)
                        {
                            // Either 'init' substring has not been found or it is not
                            // in the beginning of the method name. Either way this method
                            // is not an initializer method, so we bing it as a simple invocation
                            nativeFunction = OCSquirrelVMBindings_Instance_SimpleInvocation;
                        }
                        else
                        {
                            // Method name starts with 'init' - we have to bind it as initializer
                            // method with special treatment of the return value.
                            nativeFunction = OCSquirrelVMBindings_InitializerSimpleInvocation;
                        }
                        
                        // Set the method name as the selector string including colon if any
                        id closure =
                        [[OCSquirrelClosure alloc] initWithSQFUNCTION: nativeFunction
                                                                 name: selectorString
                                                           squirrelVM: self.squirrelVM];
                        
                        // Set the method key as the first component (without the colon character)
                        [self setObject: closure forKey: components[0]];
                    }
                }
            }];
        }
        else if (error != nil)
        {
            *error = [[NSError alloc] initWithDomain: OCSquirrelVMBindingsDomain
                                                code: OCSquirrelVMBindingsError_DoesNotRespondToSelector
                                            userInfo: nil];
            success = NO;
        }
    }
    else if (error != nil)
    {
        *error = [[NSError alloc] initWithDomain: OCSquirrelVMBindingsDomain
                                            code: OCSquirrelVMBindingsError_NativeClassNotFound
                                        userInfo: nil];
        success = NO;
    }
    
    return success;
}


- (BOOL) bindAllInstanceMethodsIncludingSuperclasses: (BOOL) includeSuperclasses
                                               error: (__autoreleasing NSError **) error
{
    BOOL success = YES;
    Class nativeClass = self.nativeClass;
    
    if (nativeClass != nil)
    {
        [self.squirrelVM doWaitPreservingStackTop: ^{
            if (includeSuperclasses)
            {
                [self bindInstanceMethodsOfNativeClassHierarchy: nativeClass];
            }
            else
            {
                [self bindInstanceMethodsOfNativeClass: nativeClass];
            }
        }];
    }
    else if (error != nil)
    {
        *error = [[NSError alloc] initWithDomain: OCSquirrelVMBindingsDomain
                                            code: OCSquirrelVMBindingsError_NativeClassNotFound
                                        userInfo: nil];
        success = NO;
    }
    
    return success;
}


#pragma mark -
#pragma mark bindings: private

/// Traverses all superclasses
- (void) bindInstanceMethodsOfNativeClassHierarchy: (Class) nativeClass
{
    if (nativeClass != [NSObject class])
    {
        [self bindInstanceMethodsOfNativeClassHierarchy: [nativeClass superclass]];
    }
    
    [self bindInstanceMethodsOfNativeClass: nativeClass];
}


/// Assumed to be called within the VM access dispatch queue
- (void) bindInstanceMethodsOfNativeClass: (Class) nativeClass
{
    unsigned int methodCount = 0;
    Method      *methods     = class_copyMethodList(nativeClass, &methodCount);
    
    for (NSUInteger index = 0; index < methodCount; ++index)
    {
        Method method = methods[index];
        
        SEL selector = method_getName(method);
        
        [self bindInstanceMethodWithSelector: selector
                                       error: nil];
    }
    
    free(methods);
}


#pragma mark -
#pragma mark class attributes

- (void) setClassAttributes: (id) attributes
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_pushnull(squirrelVM.vm);
        [squirrelVM.stack pushValue: attributes];
        
        sq_setattributes(squirrelVM.vm, -3);
    }];
}


- (id) classAttributes
{
    __block id value = nil;
    
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_pushnull(squirrelVM.vm);
        sq_getattributes(squirrelVM.vm, -2);
        
        value = [squirrelVM.stack valueAtPosition: -1];
    }];
    
    return value;
}


#pragma mark -
#pragma mark instantiation

- (void) pushNewInstance
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    __block HSQOBJECT instance;
    
    [squirrelVM doWaitPreservingStackTop: ^{
        [self push];
        sq_createinstance(squirrelVM.vm, -1);
        sq_call(squirrelVM.vm, 1, SQTrue, SQTrue);
        
        sq_getstackobj(squirrelVM.vm, -1, &instance);
        sq_addref(squirrelVM.vm, &instance);
    }];
    
    [squirrelVM doWait: ^{
        sq_pushobject(squirrelVM.vm, instance);
        sq_release(squirrelVM.vm, &instance);
    }];
}

@end
