//
//  OCSquirrelBlockInvocation.m
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 29.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <objc/runtime.h>
#import <SLBlockDescription.h>
#import "OCSquirrelBlockInvocation.h"


#pragma mark - Static globals

/** Counter for __OCSquirrelBlockInvocationInternal__ subclasses.
 *
 *  NSInvocation(OCSquirrelBlockInvocation) creates subclasses of __OCSquirrelBlockInvocationInternal__
 *  at runtime and this variable is incremented each time and used as a part of the class name to ensure
 *  uniqueness.
 */
static unsigned long g_OCSquirrelBlockInvocationIndex = 0;




#pragma mark - Static functions

/** Converts NSMethodSignature of an Objective-C block (retrieved using SLBlockDescription)
 *  into a method signature for the corresponding IMP (which we can get using a public
 *  imp_implementationWithBlock API. 
 *
 *  @param blockSignature An NSMethodSignature instance of a certain Objective-C block 
 *                        returned by SLBlockDescription of the said block.
 */
static char * const BlockMethodSignatureToImpSignature(NSMethodSignature *blockSignature)
{
    static const unsigned long kBufferSize = 1024;
    
    char * restrict impSignature = malloc(kBufferSize * sizeof(char));
    
    unsigned long offset = 0;
    
    offset += sprintf(impSignature+offset, "%s", [blockSignature methodReturnType]);
    
    // Implicit 'self' and '_cmd' params
    offset += sprintf(impSignature+offset, "@:");
    
    // Block signature also has some implicit params which we skip here, hence the starting index 2
    for (unsigned int i = 2; i < blockSignature.numberOfArguments; ++i)
    {
        offset += sprintf(impSignature+offset, "%s", [blockSignature getArgumentTypeAtIndex: i]);
    }
    
    return impSignature;
}


#pragma mark - __OCSquirrelBlockInvocationInternal__ interface

/** A private helper class used to create block-based NSInvocations.
 *
 *  @discussion Do not create instances of this class manually and do not subclass it.
 *              This class is used by NSInvocation(OCSquirrelBlockInvocation) to create
 *              subclasses in runtime and each of these subclasses is expected to have
 *              no more than a single instance at any time. When this instance is deallocated,
 *              the class is also deleted from Objective-C runtime. Undefined behavior may
 *              occur if you use this class incorrectly.
 *
 *  @see NSInvocation(OCSquirrelBlockInvocation) for more info on block-based invocations.
 */
@interface __OCSquirrelBlockInvocationInternal__ : NSInvocation
@property (nonatomic, copy) id block;
@property (nonatomic, assign) IMP blockImp;
@end


#pragma mark - __OCSquirrelBlockInvocationInternal__ implementation

@implementation __OCSquirrelBlockInvocationInternal__

- (void)dealloc
{
    imp_removeBlock(_blockImp);
    _blockImp = NULL;
    
    // Assuming self.class is one of the subclasses of __OCSquirrelBlockInvocationInternal__
    // created by NSInvocation(OCSquirrelBlockInvocation).
    //
    // This line is the very reason you should not use __OCSquirrelBlockInvocationInternal__
    // if you don't exactly know what you're doing.
    objc_disposeClassPair(self.class);
}

@end


#pragma mark - NSInvocation+OCSquirrelBlockInvocation implementation

@implementation NSInvocation (OCSquirrelBlockInvocation)

+ (instancetype)squirrelBlockInvocationWithBlock:(id)block
{
    // The general idea is to create a subclass of __OCSquirrelBlockInvocationInternal__
    // which itself inherits from NSInvocation. Then we add a new method to this class
    // with selector @selector(squirrelInvokeBlock::::) (with varying number of : depending
    // on the block parameters count) and use the IMP provided by imp_implementationWithBlock
    // as the implementation of this method.
    //
    // Then we return a standard NSInvocation which targets this newly created method of the
    // newly created class.
    //
    // The trick is that the class we're creating is itself inherited from NSInvocation and
    // its instance we've created will be set as the target of itself (no retain cycle here).
    //
    // Why do we need to create classes at runtime? Because we want to be able to create
    // a new method with the given selector each time (i.e. having different IMP for the
    // different blocks having the same signature for example). This seems not to be doable
    // in any other way.
    //
    // Note that we're creating exactly one instance of each of these newly created classes
    // and this instance -dealloc method also deletes the class, so we don't actually flood
    // the runtime with dozens of classes.
    
    IMP blockImp = imp_implementationWithBlock(block);
    
    if (blockImp == NULL) {
        return nil;
    }
    
    SLBlockDescription *blockDescription = [[SLBlockDescription alloc] initWithBlock: block];
    
    if (blockDescription == nil) {
        return nil;
    }
    
    
    // Setup IMP signature
    NSMethodSignature *blockSignature = blockDescription.blockSignature;
    
    char * const impSignatureTypes = BlockMethodSignatureToImpSignature(blockSignature);
    
    NSMethodSignature *impSignature = [NSMethodSignature signatureWithObjCTypes: impSignatureTypes];
    
    if (impSignature == nil) {
        free(impSignatureTypes);
        return nil;
    }
    
    // Constuct selector
    NSMutableString *selectorString = [NSMutableString stringWithString: @"squirrelInvokeBlock"];
    
    for (NSInteger i = 2; i < blockSignature.numberOfArguments; ++i)
    {
        [selectorString appendString: @":"];
    }
    
    SEL selector = NSSelectorFromString(selectorString);
    
    NSString *invocationClassName =
        [NSString stringWithFormat: @"NSInvocation_OCSquirrelBlockInvcation_%lu",
             g_OCSquirrelBlockInvocationIndex++];
    
    // Create __OCSquirrelBlockInvocationInternal__ subclass for the invocation
    Class invocationClass =
    objc_allocateClassPair([__OCSquirrelBlockInvocationInternal__ class],
                           [invocationClassName cStringUsingEncoding: NSASCIIStringEncoding], 0);
    
    objc_registerClassPair(invocationClass);
    
    class_addMethod(invocationClass, selector, blockImp, impSignatureTypes);
    
    // Setup invocation instance
    __OCSquirrelBlockInvocationInternal__ *invocation = (id)[invocationClass invocationWithMethodSignature: impSignature];
    
    invocation.block = block;
    invocation.blockImp = blockImp;
    
    free(impSignatureTypes);
    
    invocation.selector = selector;
    invocation.target = invocation;
    
    return invocation;
}

@end
