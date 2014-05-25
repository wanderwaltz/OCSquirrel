//
//  OCSquirrelVM.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "squirrel.h"
#import "OCSquirrelVMStack.h"


#pragma mark -
#pragma mark External declarations

@class OCSquirrelObject;
@class OCSquirrelTable;
@class OCSquirrelClass;


#pragma mark -
#pragma mark Constants

/*! Default initial stack capacity of the Squirrel VM. When initializing an OCSquirrelVM 
    instance using the -init method, the initial stack capacity will be set to this value.
 */
extern const NSUInteger kOCSquirrelVMDefaultInitialStackSize;

extern NSString * const OCSquirrelVMErrorDomain;    ///< Domain for general OCSquirrelVM errors
extern NSString * const OCSquirrelVMBindingsDomain; ///< Domain for class and method binding errors

extern NSString * const OCSquirrelVMErrorCallStackUserInfoKey;
extern NSString * const OCSquirrelVMErrorLocalsUserInfoKey;


/* Call stack report is an array of NSDictionaries having the function name, source file
   name and line numbers for these three keys respectively.
 */
extern NSString * const OCSquirrelVMCallStackFunctionKey;
extern NSString * const OCSquirrelVMCallStackSourceKey;
extern NSString * const OCSquirrelVMCallStackLineKey;


/* Locals report is an array of NSDictionaries having the local variable name and value
   for these two keys respectively.
 */
extern NSString * const OCSquirrelVMLocalNameKey;
extern NSString * const OCSquirrelVMLocalValueKey;


/// Error codes returned by the OCSquirrelVM class
enum : NSInteger
{
    /*! Is returned when the compiler function fails to get a C string from the NSString with 
        the script. This usually happens if you pass some wrong input to the function, for
        example a nil value.
     */
    OCSquirrelVMError_FailedToGetCString = 0x01,
    
    /// Is returned when a compiler error is encountered while compiling a Squirrel script.
    OCSquirrelVMError_CompilerError      = 0x02,
    
    /// Is returned when a runtime error occurs while calling the compiled Squirrel script.
    OCSquirrelVMError_RuntimeError       = 0x03,
};
    
    
enum : NSInteger
{
    /*! Is returned when trying to bind a selector to a Squirrel class which is
        not bound to a certain native Objective-C class 
     */
    OCSquirrelVMBindingsError_NativeClassNotFound      = 0x01,
    
    
    /*! Is returned when either trying to bind an instance method to a class whose
        instances do not respond to the selector provided or when trying to bind
        a class method to a class which does not respond to the provided selector.
     */
    OCSquirrelVMBindingsError_DoesNotRespondToSelector = 0x02
};


#pragma mark -
#pragma mark OCSquirrelVMDelegate protocol

@class OCSquirrelVM;

@protocol OCSquirrelVMDelegate<NSObject>
@optional

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string;
- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintError:  (NSString *) error;

@end


#pragma mark -
#pragma mark OCSquirrelVM interface

/*! An Objective-C wrapper over a single Squirrel virtual machine.
 */
@interface OCSquirrelVM : NSObject

/// Delegate for the VM which will receive printing callbacks
@property (weak, nonatomic) id<OCSquirrelVMDelegate> delegate;

/// Represents stack state of the current VM.
@property (readonly, nonatomic) id<OCSquirrelVMStack> stack;

/// Last compiler or runtime error represented as an NSError object
@property (strong, readonly, nonatomic) NSError *lastError;



#pragma mark initialization methods

/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (id) init;


/// Designated initializer
- (id) initWithStackSize: (NSUInteger) stackSize;



#pragma mark script execution

/// Compiles and executes the Squirrel script synchronously, returning the result of the script execution.
- (id) execute: (NSString *) script error: (__autoreleasing NSError **) error;

/// Block is executed synchronously
- (void) perform: (void (^)(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack)) block;

/*! Stores the current stack top value and pops everything which will be pushed above this value before returning.
 *  Should be used when you expect pushing something to the stack and don't want to bother popping it manually.
 * 
 *  Block is executed synchronously
 */
- (void) performPreservingStackTop: (void (^)(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack)) block;



#pragma mark bindings

- (OCSquirrelClass *) bindClass: (Class) aClass;

@end


#pragma mark -
#pragma mark Functions
    
/// Returns the OCSquirrelVM instance associated with a given HSQUIRRELVM
OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm);
