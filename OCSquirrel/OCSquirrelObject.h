//
//  OCSquirrelObject.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"

@class OCSquirrelVM;


#pragma mark - <OCSquirrelObject> protocol

@protocol OCSquirrelObject <NSObject>
@required

@property (nonatomic, weak, readonly) OCSquirrelVM *squirrelVM;
@property (nonatomic, assign, readonly) HSQOBJECT *obj;
@property (nonatomic, assign, readonly) SQObjectType type;

/// Pushes the object to the current VM's stack
- (void) push;

@end
