//
//  OCSquirrelArray.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 6/10/13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark OCSquirrelArray interface

@interface OCSquirrelArray : OCSquirrelObject
@property (readonly, nonatomic) NSUInteger count;

- (void) addObject: (id) object;

@end
