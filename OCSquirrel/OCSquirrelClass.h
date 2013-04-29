//
//  OCSquirrelClass.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTable.h"

#pragma mark -
#pragma mark OCSquirrelClass interface

@interface OCSquirrelClass : OCSquirrelTable
@property (readonly, nonatomic) Class nativeClass;

- (void) setClassAttributes: (id) attributes;
- (id) classAttributes;


- (void) pushNewInstance;

@end
