//
//  OCSquirrelClosure.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import <OCSquirrel/OCSquirrel.h>


#pragma mark -
#pragma mark OCSquirrelClosure interface

@interface OCSquirrelClosure : OCSquirrelObject

- (id) initWithSQFUNCTION: (SQFUNCTION) function
               squirrelVM: (OCSquirrelVM *) squirrelVM;


- (id) call;

@end
