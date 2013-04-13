//
//  OCSquirrelVM.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"


#pragma mark -
#pragma mark Constants

/*! Default initial stack capacity of the Squirrel VM. When initializing an OCSquirrelVM instance using the -init method, the initial stack capacity will be set to this value.
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
{
@protected
    HSQUIRRELVM _vm;
    
    dispatch_queue_t _vmQueue;
}

@property (weak, nonatomic) id<OCSquirrelVMDelegate> delegate;

@property (readonly, nonatomic) HSQUIRRELVM vm;

/*! Serial dispatch queue which should be used to serialize calls to Squirrel VM.
 
 Squirrel is not thread safe, so we should make sure all calls to the Squirrel VM are serialized. This can be achieved by only working with the VM on a certain serial dispatch queue. OCSquirrelVM uses vmQueue property within all its methods for vm calls, and anyone else should do the same thing if vm property needs to be accessed directly.
 */
@property (readonly, nonatomic) dispatch_queue_t vmQueue;




#pragma mark initialization methods

/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (id) init;


/// Designated initializer
- (id) initWithStackSize: (NSUInteger) stackSize;




#pragma mark script execution

- (id) executeSync: (NSString *) script;


@end
