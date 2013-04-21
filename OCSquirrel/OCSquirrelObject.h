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
    
    /*! ivar backing the squirrelVM property; maintains a strong reference to VM because the
     OCSQuirrelObject cannot actually function without a VM. Note that the OCSquirrelVM itself
     does not track OCSQuirrelObjects or retain any references to them, so no retain cycle here.
     
     We have to actually explicitly include this ivar in the class because it would not be
     authomatically synthesized for squirrelVM readonly ivar with a custom getter method.
     */
    OCSquirrelVM *_squirrelVM;
    
    /// ivar backing the obj property; note that the obj property returns _obj by reference.
    HSQOBJECT _obj;
}

/*! Will throw an exception if accessed while the value of the _squirrelVM ivar is `nil`.
    So basically OCSquirrelObject subclasses must be initialized with -initWithVM method
    with a non-nil `squirrelVM` property.
 */
@property (readonly, nonatomic) OCSquirrelVM *squirrelVM;
@property (readonly, nonatomic) HSQOBJECT *obj;

@property (readonly, nonatomic) BOOL isNull;

/// Designated initializer
- (id) initWithVM: (OCSquirrelVM *) squirrelVM;


- (id) initWithHSQOBJECT: (HSQOBJECT) object
                    inVM: (OCSquirrelVM *) squirrelVM;

@end
