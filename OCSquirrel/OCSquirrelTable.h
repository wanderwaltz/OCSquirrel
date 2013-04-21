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

- (SQInteger) integerForKey: (NSString *) key;

@end
