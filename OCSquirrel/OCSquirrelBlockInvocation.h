//
//  OCSquirrelBlockInvocation.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark - NSInvocation+OCSquirrelBlockInvocation implementation

/** A category which wraps block calls into NSInvocation objects.
 *
 *  @discussion This category relies on Objective-C runtime and blocks ABI
 *              heavily and therefore may be considered unsafe or unstable.
 *              If you prefer not using this kind of runtime trickery, you
 *              should avoid using block-based APIs of OCSquirrelClosureImpl.
 */
@interface NSInvocation (OCSquirrelBlockInvocation)

/** Creates a new NSInvocation which wraps an Objective-C block call.
 *
 *  @param block An Objective-C block which is used to create the NSInvocation.
 *
 *  @discussion In order to allow various block signatures to be used with this
 *              method, we pass block parameter as an object with id type. We
 *              still have some requirements about what kind of block can be
 *              used with this method:
 *              - blocks without parameters are allowed
 *              - if the block has at least one parameter, its first parameter
 *                should be of type id and will refer to the NSInvocation which
 *                was used to wrap this block call (this is the implicit 'this'
 *                pointer which is passed to every usual method call). Any other
 *                parameters of the block are not restricted and should be set
 *                via the NSInvocation as usual (starting from index 2).
 */
+ (instancetype)squirrelBlockInvocationWithBlock:(id)block;

@end
