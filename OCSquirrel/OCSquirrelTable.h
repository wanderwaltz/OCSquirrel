//
//  OCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"

@class OCSquirrelVM;


#pragma mark - <OCSquirrelTable> protocol

@protocol OCSquirrelTable <NSObject>
@required

- (NSUInteger)count;

- (SQInteger) integerForKey: (id) key;
- (SQFloat)     floatForKey: (id) key;
- (BOOL)         boolForKey: (id) key;
- (NSString *) stringForKey: (id) key;

- (SQUserPointer) userPointerForKey: (id) key;

- (id) objectForKey: (id) key;
- (id) objectForKeyedSubscript:(id<NSCopying>)key;

- (NSEnumerator *)keyEnumerator;


#pragma mark setter methods

- (void) setObject: (id) object forKey: (id) key;
- (void) setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

- (void) setInteger: (SQInteger)  value forKey: (id) key;
- (void)   setFloat: (SQFloat)    value forKey: (id) key;
- (void)    setBool: (BOOL)       value forKey: (id) key;
- (void)  setString: (NSString *) value forKey: (id) key;

- (void) setUserPointer: (SQUserPointer) pointer forKey: (id) key;


#pragma mark enumeration

- (void) enumerateObjectsAndKeysUsingBlock: (void (^)(id key, id value, BOOL *stop)) block;


#pragma mark calls

- (id) callClosureWithKey: (id) key;
- (id) callClosureWithKey: (id) key
               parameters: (NSArray *) parameters;

@end


#pragma mark - OCSquirrelTable interface

@interface OCSquirrelTable : NSMutableDictionary<OCSquirrelTable>

- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)vm
                           objects:(const id [])objects
                           forKeys:(const id<NSCopying> [])keys
                             count:(NSUInteger)count;

@end