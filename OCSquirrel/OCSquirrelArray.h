//
//  OCSquirrelArray.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <OCSquirrel/OCSquirrel.h>

// TODO: NSMutableArray cluster integration
// TODO: fast enumeration


#pragma mark -
#pragma mark OCSquirrelArray interface

@interface OCSquirrelArray : OCSquirrelObject
@property (readonly, nonatomic) NSUInteger count;

- (void) addObject: (id) object;

- (id) objectAtIndex: (NSInteger) index;
- (id) objectAtIndexedSubscript: (NSInteger) index;

- (void) enumerateObjectsUsingBlock: (void (^)(id object, NSInteger index, BOOL *stop)) block;

- (void) setObject: (id) object atIndex: (NSInteger) index;
- (void) setObject: (id) object atIndexedSubscript: (NSInteger) idx;

@end
