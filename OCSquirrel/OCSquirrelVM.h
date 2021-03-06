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
#pragma mark Constants

/* Default initial stack capacity of the Squirrel VM. When initializing an OCSquirrelVM
 * instance using the -init method, the initial stack capacity will be set to this value.
 */
extern const NSUInteger kOCSquirrelVMDefaultInitialStackSize;

extern NSString * const OCSquirrelVMErrorDomain;    ///< Domain for general OCSquirrelVM errors
extern NSString * const OCSquirrelVMBindingsDomain; ///< Domain for class and method binding errors

extern NSString * const OCSquirrelVMErrorCallStackUserInfoKey;
extern NSString * const OCSquirrelVMErrorLocalsUserInfoKey;


/* Call stack report is an array of NSDictionaries having the function name, source file
 * name and line numbers for these three keys respectively.
 */
extern NSString * const OCSquirrelVMCallStackFunctionKey;
extern NSString * const OCSquirrelVMCallStackSourceKey;
extern NSString * const OCSquirrelVMCallStackLineKey;


/* Locals report is an array of NSDictionaries having the local variable name and value
 * for these two keys respectively.
 */
extern NSString * const OCSquirrelVMLocalNameKey;
extern NSString * const OCSquirrelVMLocalValueKey;


// Error codes returned by the OCSquirrelVM class
enum : NSInteger
{
    /* Is returned when the compiler function fails to get a C string from the NSString with
     * the script. This usually happens if you pass some wrong input to the function, for
     * example a nil value.
     */
    OCSquirrelVMError_FailedToGetCString = 0x01,
    
    // Is returned when a compiler error is encountered while compiling a Squirrel script.
    OCSquirrelVMError_CompilerError      = 0x02,
    
    // Is returned when a runtime error occurs while calling the compiled Squirrel script.
    OCSquirrelVMError_RuntimeError       = 0x03,
};
    
    
enum : NSInteger
{
    /* Is returned when trying to bind a selector to a Squirrel class which is
     * not bound to a certain native Objective-C class
     */
    OCSquirrelVMBindingsError_NativeClassNotFound      = 0x01,
    
    
    /* Is returned when either trying to bind an instance method to a class whose
     * instances do not respond to the selector provided or when trying to bind
     * a class method to a class which does not respond to the provided selector.
     */
    OCSquirrelVMBindingsError_DoesNotRespondToSelector = 0x02
};


#pragma mark -
#pragma mark OCSquirrelVMDelegate protocol

@class OCSquirrelVM;

/** Delegate protocol for an OCSquirrelVM.
 */
@protocol OCSquirrelVMDelegate<NSObject>
@optional

/** Callback for OCSquirrelVM standard output.
 *
 *  @param squirrelVM Reference to the OCSquirrelVM which triggered the callback.
 *
 *  @param string `NSString` printed by the Squirrel standard output.
 *
 *  @discussion This callback is triggered when the `print()` function is called in
 *    a Squirrel script.
 */
- (void)squirrelVM:(OCSquirrelVM *)squirrelVM didPrintString:(NSString *)string;



/** Callback for OCSquirrelVM standard error output.
 *  @param squirrelVM Reference to the OCSquirrelVM which triggered the callback.
 *
 *  @param error `NSString` printed by the Squirrel standard output.
 *
 *  @discussion This callback is triggered when an error message is sent to the 
 *    Squirrel standard error output.
 */
- (void)squirrelVM:(OCSquirrelVM *)squirrelVM didPrintError:(NSString *)error;

@end


#pragma mark -
#pragma mark OCSquirrelVM interface

/*! An Objective-C wrapper over a single Squirrel virtual machine.
 */
@interface OCSquirrelVM : NSObject

/// Delegate for the VM which will receive printing callbacks
@property (weak, nonatomic) id<OCSquirrelVMDelegate> delegate;

/** Represents stack state of the current VM. 
 *  @see OCSquirrelVMStack for more info.
 */
@property (readonly, nonatomic) id<OCSquirrelVMStack> stack;

/// Last compiler or runtime error represented as an `NSError` object
@property (strong, readonly, nonatomic) NSError *lastError;



#pragma mark initialization methods

/** A shared singleton instance of the OCSquirrelVM class.
 *
 *  This instance will be used when creating Squirrel objects (OCSquirrelTable, OCSquirrelArray etc.)
 *  using their initializer methods without providing explicit OCSquirrelVM to bind them to.
 */
+ (instancetype)defaultVM;


/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (instancetype)init;


/** Designated initializer.
 *
 *  @param stackSize Initial stack size of the Squirrel VM.
 */
- (instancetype)initWithStackSize:(NSUInteger)stackSize;



#pragma mark script execution

/** Compiles and executes the Squirrel script synchronously, returning the result of the script execution.
 *
 *  @param script `NSString` containing the Squirrel script to execute.
 *
 *  @param error Will contain the compilation error if any.
 *
 *  @return Value returned by the script function boxed into an Objective-C object according
 *    to the rules of OCSquirrelVMStack protocol.
 */
- (id) execute: (NSString *) script error: (__autoreleasing NSError **) error;


/** Performs a given block providing the means to access the underlying `HSQUIRRELVM`.
 *
 *  @param block Objective-C block to execute.
 *
 *  @note Block is executed synchronously.
 */
- (void) perform: (void (^)(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack)) block;


/** Stores the current stack top value and pops everything which will be pushed above this value before returning.
 *  Should be used when you expect pushing something to the stack and don't want to bother popping it manually.
 *
 *  @param block Objective-C block to execute.
 * 
 *  @note Block is executed synchronously
 */
- (void) performPreservingStackTop: (void (^)(HSQUIRRELVM vm, id<OCSquirrelVMStack> stack)) block;

@end


#pragma mark -
#pragma mark Functions
    
/// Returns the OCSquirrelVM instance associated with a given HSQUIRRELVM
OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm);
