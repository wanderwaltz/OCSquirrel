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

/** Internal implementation of OCSquirrelObject protocol.
 */
@interface OCSquirrelObjectImpl : NSObject<NSCopying, OCSquirrelObject>
{
@protected
    /// ivar backing the obj property; note that the obj property returns _obj by reference.
    HSQOBJECT _obj;
}

#pragma mark properties

@property (weak, readonly, nonatomic) OCSquirrelVM *squirrelVM;
@property (readonly, nonatomic) HSQOBJECT *obj;

@property (readonly, nonatomic) BOOL isNull;
@property (readonly, nonatomic) SQObjectType type;


#pragma mark initializers

/// Designated initializer
- (id)initWithVM:(OCSquirrelVM *)squirrelVM;


- (id)initWithHSQOBJECT:(HSQOBJECT)object
                   inVM:(OCSquirrelVM *)squirrelVM;


/// Pushes the object to the current VM's stack
- (void)push;



#pragma mark class methods

+ (BOOL)isAllowedToInitWithSQObjectOfType:(SQObjectType)type;

+ (id)newWithVM:(OCSquirrelVM *)squirrelVM;

+ (id)newWithHSQOBJECT:(HSQOBJECT)object
                  inVM:(OCSquirrelVM *)squirrelVM;


#pragma mark unavailable methods

+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

@end
