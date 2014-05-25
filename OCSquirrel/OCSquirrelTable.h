//
//  OCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObject.h"

// TODO: fast enumeration of keys similar to NSDictionary's
// TODO: NSMutableDictionary cluster integration
// TODO: -hasObjectForKey:

#pragma mark -
#pragma mark OCSquirrelTable interface

@interface OCSquirrelTable : OCSquirrelObject

+ (id) rootTableForVM:     (OCSquirrelVM *) squirrelVM;
+ (id) registryTableForVM: (OCSquirrelVM *) squirrelVM;


#pragma mark getter methods

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
