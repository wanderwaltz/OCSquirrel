//
//  OCSquirrelInstanceImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 27.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelTableImpl.h"
#import "OCSquirrelInstance.h"


#pragma mark -
#pragma mark OCSquirrelInstanceImpl interface

@interface OCSquirrelInstanceImpl : OCSquirrelTableImpl<OCSquirrelInstance>
@property (readonly, nonatomic) id instanceUP;
@end
