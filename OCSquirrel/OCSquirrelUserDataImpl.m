//
//  OCSquirrelUserDataImpl.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelUserDataImpl.h"
#import "OCSquirrelVMFunctions_NoARC.h"

@implementation OCSquirrelUserDataImpl

+ (BOOL)isAllowedToInitWithSQObjectOfType:(SQObjectType)type
{
    return (type == OT_USERDATA);
}


- (id)object
{
    __block id result = nil;
    
    [self.squirrelVM performPreservingStackTop:^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack) {
        [self push];
        SQUserPointer udp = NULL;
        sq_getuserdata(vm, -1, &udp, NULL);
        
        if (udp != NULL) {
            result = OCSquirrelVM_UserDataGetObject(udp);
        }
    }];
    
    return result;
}


- (instancetype)initWithVM:(OCSquirrelVM *)squirrelVM
{
    return [self initWithObject: nil
                           inVM: squirrelVM];
}


- (instancetype)initWithObject:(id)object
                          inVM:(OCSquirrelVM *)squirrelVM
{
    self = [super initWithVM: squirrelVM];
    
    if (self != nil) {
        
        __block BOOL failed = NO;
        
        [squirrelVM performPreservingStackTop: ^(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack){
            sq_newuserdata(vm, sizeof(object));
            
            SQUserPointer udp = NULL;
            
            sq_getuserdata(vm, -1, &udp, NULL);
            
            if (udp == NULL) {
                failed = YES;
                return;
            }
            
            OCSquirrelVM_UserDataSetObject(udp, object);
        
            sq_setreleasehook(vm, -1, OCSquirrelVM_UserDataReleaseHook);
            
            sq_getstackobj(vm, -1, &_obj);
            sq_addref(vm, &_obj);
        }];
        
        if (failed) {
            return nil;
        }
    }
    return self;
}

@end
