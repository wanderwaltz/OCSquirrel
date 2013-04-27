//
//  OCSquirrelObject.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"


#pragma mark -
#pragma mark OCSquirrelObject interface

@interface OCSquirrelObject : NSObject
{
@protected
    /// ivar backing the obj property; note that the obj property returns _obj by reference.
    HSQOBJECT _obj;
}

/*! Will throw an exception if accessed while the value of the _squirrelVM ivar is `nil`.
    So basically OCSquirrelObject subclasses must be initialized with -initWithVM method
    with a non-nil `squirrelVM` property.
 */
@property (weak, readonly, nonatomic) OCSquirrelVM *squirrelVM;
@property (readonly, nonatomic) HSQOBJECT *obj;

@property (readonly, nonatomic) BOOL isNull;

/// Designated initializer
- (id) initWithVM: (OCSquirrelVM *) squirrelVM;


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM;


/// Pushes the object to the current VM's stack
- (void) push;

@end
