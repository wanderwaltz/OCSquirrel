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

extern const NSUInteger kOCSquirrelVMDefaultInitialStackSize;


#pragma mark -
#pragma mark OCSquirrelVM interface

@interface OCSquirrelVM : NSObject
{
@protected
    HSQUIRRELVM _vm;
    
    dispatch_queue_t _vmQueue;
}

@property (readonly, nonatomic) HSQUIRRELVM vm;
@property (readonly, nonatomic) dispatch_queue_t vmQueue;


/// Defaults stack size to kOCSquirrelVMDefaultInitialStackSize
- (id) init;


/// Designated initializer
- (id) initWithStackSize: (NSUInteger) stackSize;

@end
