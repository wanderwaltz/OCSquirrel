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

/*! Default initial stack capacity of the Squirrel VM. When initializing an OCSquirrelVM 
    instance using the -init method, the initial stack capacity will be set to this value.
 */
extern const NSUInteger kOCSquirrelVMDefaultInitialStackSize;

extern NSString * const OCSquirrelVMErrorDomain;
extern NSString * const OCSquirrelVMErrorCallStackUserInfoKey;

enum : NSInteger
{
    OCSquirrelVMError_FailedToGetCString = 0x01,
    OCSquirrelVMError_CompilerError      = 0x02,
    OCSquirrelVMError_FailedToCallScript = 0x03,
    OCSquirrelVMError_RuntimeError       = 0x04
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

- (void) bindClass: (Class) aClass;


#pragma mark general dispatch

/// Performs block on the vmQueue; does not lead to deadlock if called within a block already on vmQueue
- (void) doWait: (dispatch_block_t) block;

@end
