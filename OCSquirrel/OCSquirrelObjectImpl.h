//
//  OCSquirrelObjectImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"
#import "OCSquirrelObject.h"


#pragma mark -
#pragma mark OCSquirrelObjectImpl interface

@interface OCSquirrelObjectImpl : NSObject<OCSquirrelObject>
{
@protected
    /// ivar backing the obj property; note that the obj property returns _obj by reference.
    HSQOBJECT _obj;
}

@property (weak, readonly, nonatomic) OCSquirrelVM *squirrelVM;
@property (readonly, nonatomic) HSQOBJECT *obj;

@property (readonly, nonatomic) BOOL isNull;
@property (readonly, nonatomic) SQObjectType type;

/// Designated initializer
- (id) initWithVM: (OCSquirrelVM *) squirrelVM;


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM;


/// Pushes the object to the current VM's stack
- (void) push;


+ (BOOL) isAllowedToInitWithSQObjectOfType: (SQObjectType) type;

+ (id) newWithVM: (OCSquirrelVM *) squirrelVM;

+ (id) newWithHSQOBJECT: (HSQOBJECT) object
                   inVM: (OCSquirrelVM *) squirrelVM;

@end
