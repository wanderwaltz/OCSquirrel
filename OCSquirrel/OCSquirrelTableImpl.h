//
//  OCSquirrelTableImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObject.h"
#import "OCSquirrelTable.h"

// TODO: fast enumeration of keys similar to NSDictionary's
// TODO: -hasObjectForKey:

#pragma mark -
#pragma mark OCSquirrelTableImpl interface

@interface OCSquirrelTableImpl : OCSquirrelObject<OCSquirrelTable>

+ (id) rootTableForVM:     (OCSquirrelVM *) squirrelVM;
+ (id) registryTableForVM: (OCSquirrelVM *) squirrelVM;

@end
