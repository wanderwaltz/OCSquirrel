//
//  OCSquirrelUserData.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 31.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelObject.h"

#pragma mark -
#pragma mark <OCSquirrelUserData> protocol

@protocol OCSquirrelUserData<NSObject, OCSquirrelObject>
@required

- (id)object;

@end


#pragma mark -
#pragma mark OCSquirrelUserData interface

@interface OCSquirrelUserData : NSObject<OCSquirrelUserData>

- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObject:(id)object
                  inSquirrelVM:(OCSquirrelVM *)squirrelVM;

@end
