//
//  OCSQuirrelVMStack.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark OCSquirrelVMStack protocol

/** Protocol for working with OCSquirrelVM stack.
 *
 *  Squirrel API relies heavily on the stack operations. This protocol provides convenient
 *  interface for working with OCSquirrelVM stack. Many other classes of the OCSquirrel framework
 *  internally depend on the OCSquirrelVMStack protocol so the type conversion conventions described
 *  below will also take place in case of these classes.
 *
 *  Type conversion
 *  ---------------
 *
 *  Some common rules are expected from all OCSquirrelVMStack implementations regarding
 *  working with Objective-C types:
 *
 *  - Integers are converted to `SQInteger` type
 *  - Floating point types are converted to `SQFloat` type
 *  - Squirrel's `bool` type is represented by `BOOL` and vice versa
 *  - Squirrel strings are represented by `NSString` values
 *  - Squirrel `nil` is represented by either `nil` or `NSNull` where appropriate
 *
 *  For methods accepting or returning values of `id` type the following rules should apply:
 *
 *  _When reading values from `OCSquirrelVMStack`_
 *
 *  - Integers, floats and booleans are represented by `NSNumber` values
 *  - User pointer objects are represented by `NSValue`
 *  - Squirrel strings are represented by `NSString` values
 *  - Squirrel tables are represented by objects of `OCSquirrelTable` class
 *  - Squirrel arrays are represented by objects of `OCSquirrelArray` class
 *  - Squirrel classes are represented by objects of `OCSquirrelClass` class
 *  - Squirrel class instances are represented by objects of `OCSquirrelInstance` class
 *  - Squirrel user data objects are represented by objects of `OCSquirrelUserData` class
 *  - Squirrel closures are represented by `OCSquirreClosure` class
 *  - Anonymous objects conforming to OCSquirrelObject protocol may be returned in other cases
 *
 *  _When pushing values to `OCSquirrelVMStack`_
 *
 *  - `NSNumber` values are converted to the corresponding scalars
 *  - `NSString` values are converted to Squirrel strings using UTF-8 encoding.
 *  - Classes conforming to `OCSquirrelObject` protocol are pushed using their [OCSquirrelObject push] method
 *  - `NSArray` and `NSDictionary` objects are automatically converted to `OCSquirrelArray` 
 *  and `OCSquirrelDictionary` instances respectively.
 *  - Objective-C classes which are unknown to the Squirrel VM are represented as objects of
 *  user pointer type.
 *
 *  Stack indexation
 *  ----------------
 *
 *  All methods used to read values from the stack accept an `SQInteger` position parameter. Both
 *  positive and negative positions are accepted. Negative indexes wrap from the top side of the
 *  stack (so -1 always points to the element on top of the stack).
 */
@protocol OCSquirrelVMStack<NSObject>
@required

/** @name Properties */


/** Number of values currently contained in the Squirrel VM stack.
 *  
 *  Setting this property to a value less than current effectively
 *  pops multiple items from the stack. Settings this property to
 *  a value greater than current will push an appropriate number of
 *  `null`s to the top of the stack.
 *
 *  @exception NSInvalidArgumentException Is thrown when trying to set
 *    a negative value to this property.
 */
@property (assign, nonatomic) NSInteger top;

#pragma mark pushing methods

/** @name Pushing values to the stack */

/** Pushes a given `SQInteger` on top of the Squirrel VM stack.
 *
 *  @param value `SQInteger` value to be pushed.
 */
- (void)pushInteger:(SQInteger)value;


/** Pushes a given `SQFloat` on top of the Squirrel VM stack.
 *
 *  @param value `SQFloat` value to be pushed.
 */
- (void)pushFloat:(SQFloat)value;


/** Pushes a given `BOOL` on top of the Squirrel VM stack.
 *
 *  @param value `BOOL` value to be pushed.
 *
 *  @note Internally Squirrel has a separate type alias for representing booleans,
 *    `SQBool`, with constants `SQFalse` and `SQTrue` provided. OCSquirrel APIs
 *    work with `BOOL` type for convenience and provide conversions automatically.
 *
 */
- (void)pushBool:(BOOL)value;


/** Pushes a given `NSString` on top of the Squirrel VM stack.
 *
 *  @param string `NSString` value to be pushed.
 *
 */
- (void)pushString:(NSString *)string;


/** Pushes a given `SQUserPointer` on top of the Squirrel VM stack.
 *
 *  @param pointer `SQUserPointer` value to be pushed.
 */
- (void)pushUserPointer:(SQUserPointer)pointer;


/** Pushes a given `HSQOBJECT` on top of the Squirrel VM stack.
 *
 *  @param object `HSQOBJECT` value to be pushed.
 */
- (void)pushSQObject:(HSQOBJECT)object;


/** Pushes `null` value on top of the Squirrel VM stack.
 */
- (void)pushNull;


/** Pushes a given Objective-C object on top of the Squirrel VM stack.
 *
 *  @param value Object to be pushed.
 *
 *  @discussion Automatic unboxing and/or type conversion is applied according
 *    to the rules described above.
 */
- (void)pushValue:(id)value;


#pragma mark reading methods

/** @name Reading values from the stack */

/** Reads an `SQInteger` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `SQInteger` value read. If the element of the stack at the given position is not of integer
 *    type, returns 0.
 *
 *  @discussion Does not pop any values from the stack.
 */
- (SQInteger)integerAtPosition:(SQInteger)position;



/** Reads an `SQFloat` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `SQFloat` value read. If the element of the stack at the given position is not of float
 *    type, returns 0.0.
 *
 *  @discussion Does not pop any values from the stack.
 */

- (SQFloat)floatAtPosition:(SQInteger)position;



/** Reads an `BOOL` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `BOOL` value read. If the element of the stack at the given position is not of boolean
 *    type, returns NO.
 *
 *  @discussion Does not pop any values from the stack.
 */
- (BOOL)boolAtPosition:(SQInteger)position;



/** Reads an `NSString` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `NSString` value read. If the element of the stack at the given position is not of string
 *    type, returns `nil`.
 *
 *  @discussion Does not pop any values from the stack.
 */
- (NSString *)stringAtPosition:(SQInteger)position;



/** Reads an `SQUserPointer` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `SQUserPointer` value read. If the element of the stack at the given position is not of user pointer
 *    type, returns `NULL`.
 *
 *  @discussion Does not pop any values from the stack.
 */
- (SQUserPointer)userPointerAtPosition:(SQInteger)position;



/** Reads an `HSQOBJECT` value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `HSQOBJECT` value read. If the element of the stack at the given position is not of boolean
 *    type, returns `null` object.
 *
 *  @discussion Does not pop any values from the stack. Does not alter the reference count of the `HSQOBJECT`.
 */
- (HSQOBJECT)sqObjectAtPosition:(SQInteger)position;



/** Reads an Objective-C value from the given position of the Squirrel VM stack.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return Objective-C value read. Applies automatic boxing/type conversion rules as described above.
 *
 *  @discussion Does not pop any values from the stack.
 */
- (id)valueAtPosition:(SQInteger)position;




#pragma mark type information

/** @name Type information */

/** Checks whenther the given stack position contains `null` value.
 *
 *  @param position Index of the element in the stack. Wraps around zero (so -1 always points to the
 *    element on top of the stack).
 *
 *  @return `YES` if the value at the given position of the stack is `null`.
 */
- (BOOL)isNullAtPosition:(SQInteger)position;

@end