//
//  OCSquirrelInstance.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTableImpl.h"


#pragma mark -
#pragma mark OCSquirrelInstance interface

@interface OCSquirrelInstance : OCSquirrelTableImpl
@property (readonly, nonatomic) id instanceUP;
@end
