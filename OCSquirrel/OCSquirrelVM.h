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


#pragma mark -
#pragma mark OCSquirrelVMDelegate protocol

@class OCSquirrelVM;

@protocol OCSquirrelVMDelegate<NSObject>
@optional

- (void) squirrelVM: (OCSquirrelVM *) squirrelVM didPrintString: (NSString *) string;

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



#pragma mark initialization methods

/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (id) init;


/// Designated initializer
- (id) initWithStackSize: (NSUInteger) stackSize;




#pragma mark script execution

/*! Compiles and executes the Squirrel script synchronously, returning the result of the script execution.
 
 This method is designed to be called when an immediate result is needed, and does throw 
 NSInvalidArgumentException if compiling the script failed. May also throw an
 NSInternalInconsistencyException, but this is an unusual case and should generally never happen.
 
 It is recommended to use NSError-based error handling for expected errors, and it would make more sense 
 to do that if the app could run the code from some unexpected source so that the compilation errors 
 would be possible etc. But since Apple forbids iOS applications to download executable code in any form, 
 we may expect all scripts passed to this method to be either hard-coded or read from the resource files 
 included in the application bundle. So any compilation errors which may happen with these scripts will 
 most likely be fixed at the time of application developing, and exceptions seem to be a more sensible 
 way to handle these.
 
 */
- (id) executeSync: (NSString *) script;


#pragma mark general dispatch

/// Performs block on the vmQueue; does not lead to deadlock if called within a block already on vmQueue
- (void) doWait: (dispatch_block_t) block;

@end
