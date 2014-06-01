//
//  OCSquirrelClassImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTableImpl.h"
#import "OCSquirrelClass.h"

// TODO: chained invocations

#pragma mark -
#pragma mark OCSquirrelClassImpl interface

/** Internal implementation of OCSquirrelClass protocol.
 */
@interface OCSquirrelClassImpl : OCSquirrelTableImpl<OCSquirrelClass>

/** @name <OCSquirrelClass> */

@property (readonly, nonatomic) Class nativeClass;


/** @name initialization methods */

/** Initializes the OCSquirrelClassImpl instance with a bound native class.
 *
 *  @param nativeClass Objective-C class to bind with the Squirrel class. May be `nil`.
 *
 *  @param squirrelVM Squirrel VM to be associated with the OCSquirrelClassImpl.
 *
 *  @return An OCSquirrelClassImpl instance bound to the given Objective-C class.
 *
 *  @discussion Sets the type tag of the Squirrel class to the native class provided.
 *    Passing `nil` as the `nativeClass` parameter creates a new empty Squirrel class
 *    not bound to any Objective-C classes.
 *
 *  @note Does not bind the constructor method of the Squirrel class. This is done by
 *    the Squirrel VM in its [OCSquirrelVM bindClass:] method.
 *
 */
- (instancetype)initWithNativeClass:(Class)nativeClass
                               inVM:(OCSquirrelVM *)squirrelVM;

/** @name <OCSquirrelClass> */

/** Sets the class attributes of the receiver.
 *
 *  @param attributes Objective-C object representing the class attributes to be set.
 *    This object is unboxed into a Squirrel value according to the rules of the 
 *    OCSquirrelVMStack protocol.
 *
 */
- (void)setClassAttributes:(id)attributes;

/** Returns the class attributes of the receiver as an Objective-C object.
 *
 *  @return Class attributes of the receiver. Return value is boxed into an Objective-C object
 *    according to the rules of OCSquirrelVMStack protocol.
 */
- (id)classAttributes;


/** Creates a new instance of the class and pushes it into the Squirrel VM stack.
 *
 *  @discussion Creates a new instance of the class using default constructor with no
 *    parameters and pushes the resulting instance into the Squirrel VM stack. 
 *
 *  Note that for the bound native classes Squirrel constructor performs only `alloc`
 *  operation, but does not initialize the created Objective-C object. One of the
 *  initializer methods should be immediately called after creating a new bound class
 *  instance.
 */
- (void)pushNewInstance;



/** Binds instance method with the given selector.
 *
 *  @param selector A selector of the instance method to bind.
 *
 *  @param error A pointer to `NSError*` value which will contain an error object if something
 *    goes wrong.
 *
 *  @return A `BOOL` value indicating whether the binding was completed successfully or not.
 *
 *  @discussion 'Binding a method' in context of OCSquirrelClassImpl means making this method
 *    accessible from the Squirrel scripts. The parameters passed to the corresponding Squirrel
 *    method will be automatically adjusted if needed to match their Objective-C counterparts
 *    (this way Squirrel's `bool` will become Objective-C `BOOL`, Squirrel strings will be
 *    passed as `NSString`s etc.) 
 */
- (BOOL)bindInstanceMethodWithSelector:(SEL)selector
                                 error:(__autoreleasing NSError **)error;



/** Binds all instance methods of the corresponding native class.
 *
 *  @param includeSuperclasses If this parameter is set to YES, the class hierarchy
 *    is traversed recursively to bind all instance methods of all the superclasses.
 *
 *  @param error A pointer to `NSError*` value which will contain an error object if something
 *    goes wrong.
 *
 *  @return A `BOOL` value indicating whether the binding was completed successfully or not.
 *
 *  @discussion Uses Objective-C runtime functions to iterate through all methods of the corresponding
 *    native class and bind them to the Squirrel class. This is potentially dangerous operation
 *    since this also makes 'private', i.e. not usually visible methods accessible and is
 *    generally resource consuming especially if `includeSuperclasses` is set to YES (for example
 *    traversing the `NSObject`'s list of methods gives us 120 methods to bind).
 *
 *    Use with caution. It is generally safer to bind only several needed methods using
 *    bindInstanceMethodWithSelector:error:
 */
- (BOOL)bindAllInstanceMethodsIncludingSuperclasses:(BOOL)includeSuperclasses
                                              error:(__autoreleasing NSError **)error;

@end
