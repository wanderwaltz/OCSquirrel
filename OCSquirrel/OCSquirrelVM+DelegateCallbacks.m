//
//  OCSquirrelVM+DelegateCallbacks.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#if (!__has_feature(objc_arc))
#error "This file should be compiled with ARC support"
#endif

#import "OCSquirrelVM+DelegateCallbacks.h"


#pragma mark -
#pragma mark OCSquirrelVM+DelegateCallbacks implementation

@implementation OCSquirrelVM (DelegateCallbacks)

- (void) _delegate_didPrintString: (NSString *) string
{
    if ([self.delegate respondsToSelector: @selector(squirrelVM:didPrintString:)])
    {
        [self.delegate squirrelVM: self
                   didPrintString: string];
    }
}

@end
