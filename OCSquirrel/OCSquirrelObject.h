//
//  OCSquirrelObject.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 28.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCSquirrelVM;


#pragma mark - <OCSquirrelObject> protocol

@protocol OCSquirrelObject <NSObject>
@required

@property (weak, readonly, nonatomic) OCSquirrelVM *squirrelVM;

/// Pushes the object to the current VM's stack
- (void) push;

@end
