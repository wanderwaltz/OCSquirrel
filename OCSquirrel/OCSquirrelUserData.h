//
//  OCSquirrelUserData.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 31.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelObject.h"

#pragma mark -
#pragma mark <OCSquirrelUserData> protocol

/** Interface for boxing arbitrary Objective-C objects into Squirrel objects.
 */
@protocol OCSquirrelUserData<NSObject, OCSquirrelObject>
@required

/** Returns Objective-C object associated with OCSquirrelUserData instance.
 */
- (id)object;

@end


#pragma mark -
#pragma mark OCSquirrelUserData interface

/** Default implementation of OCSquirrelUserData protocol.
 */
@interface OCSquirrelUserData : NSObject<OCSquirrelUserData>

/** Initializes the OCSquirrelUserData with a given object and a default Squirrel VM.
 *
 *  @param object Objective-C object to associate with the receiver. Object is referenced strongly
 *     by the OCSquirrelUserData. May be `nil`.
 *
 *  @discussion OCSquirrelUserData instance is initialized with the default Squirrel VM returned
 *    by the [OCSquirrelVM defaultVM].
 */
- (instancetype)initWithObject:(id)object;


/** Initializes the OCSquirrelUserData with a given object and the Squirrel VM provided.
 *
 *  @param object Objective-C object to associate with the receiver. Object is referenced strongly
 *     by the OCSquirrelUserData. May be `nil`.
 *
 *  @param squirrelVM Squirrel VM to associate with the receiver. Cannot be `nil`.
 *
 *  @exception NSInvalidArgumentException Is thrown when passing `nil` as the `squirrelVM` parameter.
 */
- (instancetype)initWithObject:(id)object
                  inSquirrelVM:(OCSquirrelVM *)squirrelVM;

@end
