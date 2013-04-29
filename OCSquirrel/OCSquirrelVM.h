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

extern NSString * const OCSquirrelVMErrorDomain;
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
    OCSquirrelVMError_RuntimeError       = 0x03
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

@interface OCSquirrelVM : NSObject
@property (weak, nonatomic) id<OCSquirrelVMDelegate> delegate;

@property (readonly, nonatomic) HSQUIRRELVM vm;

/*! Serial dispatch queue which should be used to serialize calls to Squirrel VM.
 
 Squirrel is not thread safe, so we should make sure all calls to the Squirrel VM are serialized. 
 This can be achieved by only working with the VM on a certain serial dispatch queue. OCSquirrelVM 
 uses vmQueue property within all its methods for vm calls, and anyone else should do the same 
 thing if vm property needs to be accessed directly.
 */
@property (readonly, nonatomic) dispatch_queue_t vmQueue;


@property (readonly, nonatomic) id<OCSquirrelVMStack> stack;

@property (strong, readonly, nonatomic) NSError *lastError;



#pragma mark initialization methods

/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (id) init;


/// Designated initializer
- (id) initWithStackSize: (NSUInteger) stackSize;




#pragma mark script execution

/// Compiles and executes the Squirrel script synchronously, returning the result of the script execution.
- (id) executeSync: (NSString *) script error: (__autoreleasing NSError **) error;


#pragma mark bindings

- (OCSquirrelClass *) bindClass: (Class) aClass;


#pragma mark general dispatch

/// Performs block on the vmQueue; does not lead to deadlock if called within a block already on vmQueue
- (void) doWait: (dispatch_block_t) block;

/*! Does the same as -doWait:, but stores the current stack top value and pops everything from the stack
    which will be pushed above this value. Should be used when you expect pushing something to the stack
    and don't want to bother popping it manually. If you pop something from the stack without pushing,
    results may be unpredictable.
 */
- (void) doWaitPreservingStackTop: (dispatch_block_t) block;

@end


#pragma mark -
#pragma mark Functions
    
/// Returns the OCSquirrelVM instance associated with a given HSQUIRRELVM
OCSquirrelVM *OCSquirrelVMforVM(HSQUIRRELVM vm);
