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

/** Initializes OCSquirrelObject as belonging to a given Squirrel VM.
 *
 *  @param squirrelVM An OCSquirrelVM instance. Should not be nil.
 */
- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM;


- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)squirrelVM
                         HSQOBJECT:(HSQOBJECT)object;


/// Pushes the object to the current VM's stack
- (void)push;



#pragma mark class methods

+ (BOOL)isAllowedToInitWithSQObjectOfType:(SQObjectType)type;

+ (id)newWithSquirrelVM:(OCSquirrelVM *)squirrelVM;

+ (id)newWithSquirrelVM:(OCSquirrelVM *)squirrelVM
              HSQOBJECT:(HSQOBJECT)obj;


#pragma mark unavailable methods

+ (instancetype)new __unavailable;
- (instancetype)init __unavailable;

@end
