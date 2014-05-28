//
//  OCSquirrelClosure.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelClosure.h"
#import "OCSquirrelVM+SQObjects.h"
#import "OCSquirrelTable.h"


#pragma mark -
#pragma mark OCSquirrelClosure implementation

@implementation OCSquirrelClosure

#pragma mark -
#pragma mark class methods

+ (BOOL)isAllowedToInitWithSQObjectOfType:(SQObjectType)type
{
    return (type == OT_CLOSURE) || (type == OT_NATIVECLOSURE);
}


#pragma mark -
#pragma mark initialization methods

- (id)initWithSQFUNCTION:(SQFUNCTION)function
              squirrelVM:(OCSquirrelVM *)squirrelVM
{
    return [self initWithSQFUNCTION: function
                               name: nil
                         squirrelVM: squirrelVM];
}


- (id)initWithSQFUNCTION:(SQFUNCTION)function
                    name:(NSString *)name
              squirrelVM:(OCSquirrelVM *)squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil)
    {
        [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            sq_newclosure(vm, function, 0);
            sq_getstackobj(vm, -1, &_obj);
            sq_addref(vm, &_obj);
            
            if (name != nil)
            {
                const SQChar *cName = [name cStringUsingEncoding: NSUTF8StringEncoding];
                
                if (cName != NULL)
                    sq_setnativeclosurename(vm, -1, cName);
            }
        }];
    }
    return self;
}


#pragma mark -
#pragma mark methods

- (id)call
{
    return [self callWithThis: [self.squirrelVM rootTable]
                   parameters: nil];
}


- (id)call:(NSArray *)parameters
{
    return [self callWithThis: [self.squirrelVM rootTable]
                   parameters: parameters];
}


- (id)callWithThis:(id<OCSquirrelObject>)this
{
    return [self callWithThis: this
                   parameters: nil];
}


- (id)callWithThis:(id<OCSquirrelObject>)this
        parameters:(NSArray *)parameters
{
    OCSquirrelVM *squirrelVM = self.squirrelVM;
    
    __block id result = nil;
    
    [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
        [self push]; // Pushes the closure to the stack
        [this push]; // Pushes the 'this' object to the stack
        
        for (id parameter in parameters)
        {
            [stack pushValue: parameter];
        }
        
        // Parameters count is at least 1 since the first parameter is
        // always the 'this' object.
        sq_call(vm, parameters.count+1, SQTrue, SQTrue);
        result = [stack valueAtPosition: -1];
    }];
    
    return result;
}

@end
