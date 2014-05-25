//
//  OCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "squirrel.h"

// TODO: implement NSMutableDictionary cluster integration
// Idea is the following: implement NSMutableDictionary subclass named OCSquirrelTable
// which will conform to OCSquirrelTable protocol and will contain an OCSquirrelTableImpl
// object inside itself. This class will forward OCSquirrelTable protocol methods to its
// OCSquirrelTableImpl.

@protocol OCSquirrelTable <NSObject>
@required

- (SQInteger) integerForKey: (id) key;
- (SQFloat)     floatForKey: (id) key;
- (BOOL)         boolForKey: (id) key;
- (NSString *) stringForKey: (id) key;

- (SQUserPointer) userPointerForKey: (id) key;

- (id) objectForKey: (id) key;
- (id) objectForKeyedSubscript:(id<NSCopying>)key;


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
