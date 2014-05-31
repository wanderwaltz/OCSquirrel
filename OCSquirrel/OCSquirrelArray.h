//
//  OCSquirrelArray.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 26.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelObject.h"

@class OCSquirrelVM;


#pragma mark - <OCSquirrelArray> protocol

@protocol OCSquirrelArray <NSObject, OCSquirrelObject>
@required

- (NSUInteger)count;

- (void)addObject:(id)object;

- (id)objectAtIndex:(NSInteger)index;
- (id)objectAtIndexedSubscript:(NSInteger)index;

- (void)enumerateObjectsUsingBlock:(void (^)(id object, NSInteger index, BOOL *stop))block;

- (void)setObject:(id)object atIndex:(NSInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSInteger)idx;

- (void)insertObject:(id)anObject atIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;

- (id)pop;

@end


#pragma mark - OCSquirrelArray class interface

@interface OCSquirrelArray : NSMutableArray<OCSquirrelArray>

- (instancetype)initWithVM:(OCSquirrelVM *)vm;

@end
