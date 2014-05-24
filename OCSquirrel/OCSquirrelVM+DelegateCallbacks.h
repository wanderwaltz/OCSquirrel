//
//  OCSquirrelVM+DelegateCallbacks.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 13.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelVM.h"


#pragma mark -
#pragma mark OCSquirrelVM+DelegateCallbacks interface

@interface OCSquirrelVM (DelegateCallbacks)

- (void) _delegate_didPrintString: (NSString *) string;
- (void) _delegate_didPrintError:  (NSString *) error;

@end
