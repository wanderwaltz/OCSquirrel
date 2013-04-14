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

@protocol OCSquirrelVMStack<NSObject>
@property (assign, nonatomic) NSInteger top;
@end