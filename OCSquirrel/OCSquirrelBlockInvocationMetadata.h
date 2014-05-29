//
//  OCSquirrelBlockInvocationMetadata.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - OCSquirrelBlockInvocationMetadata interface

@interface OCSquirrelBlockInvocationMetadata : NSObject
@property (nonatomic, copy, readonly) id block;
@property (nonatomic, assign, readonly) IMP blockImp;

- (instancetype)initWithBlock:(id)block
                          imp:(IMP)blockImp;

@end
