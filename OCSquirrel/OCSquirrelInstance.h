//
//  OCSquirrelInstance.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 01.06.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelObject.h"


#pragma mark - <OCSquirrelInstance> protocol

@protocol OCSquirrelInstance<NSObject, OCSquirrelObject>
@required

#pragma mark - properties

- (id)instanceUP;

#pragma mark - accessors

- (id)objectForKey:(id)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

- (void)setObject:(id)object forKey:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

#pragma mark - method callers

- (id)callClosureWithKey:(id)key;
- (id)callClosureWithKey:(id)key
              parameters:(NSArray *)parameters;

@end


#pragma mark - OCSquirrelInstance interface

@interface OCSquirrelInstance : NSObject<OCSquirrelInstance>

@end
