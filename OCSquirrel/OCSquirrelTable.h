//
//  OCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObject.h"


#pragma mark -
#pragma mark OCSquirrelTable interface

@interface OCSquirrelTable : OCSquirrelObject

+ (id) rootTableForVM: (OCSquirrelVM *) squirrelVM;


#pragma mark getter methods

- (SQInteger) integerForKey: (id) key;
- (SQFloat)     floatForKey: (id) key;
- (BOOL)         boolForKey: (id) key;
- (NSString *) stringForKey: (id) key;

- (SQUserPointer) userPointerForKey: (id) key;

- (id) objectForKey: (id) key;


#pragma mark setter methods

- (void) setObject: (id) object forKey: (id) key;

- (void) setInteger: (SQInteger)  value forKey: (id) key;
- (void)   setFloat: (SQFloat)    value forKey: (id) key;
- (void)    setBool: (BOOL)       value forKey: (id) key;
- (void)  setString: (NSString *) value forKey: (id) key;

- (void) setUserPointer: (SQUserPointer) pointer forKey: (id) key;

@end