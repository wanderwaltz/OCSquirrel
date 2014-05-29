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
#import "OCSquirrelBlockInvocationMetadata.h"


#pragma mark - Static globals

static unsigned long g_OCSquirrelBlockInvocationIndex = 0;
static const void * const kAssotiationKeyOCSquirrelBlockInvocationMetadata =
    &kAssotiationKeyOCSquirrelBlockInvocationMetadata;


#pragma mark - Static functions

static char * const BlockMethodSignatureToImpSignature(NSMethodSignature *blockSignature)
{
    static const unsigned long kBufferSize = 1024;
    
    char * restrict impSignature = malloc(kBufferSize * sizeof(char));
    
    unsigned long offset = 0;
    
    offset += sprintf(impSignature+offset, "%s", [blockSignature methodReturnType]);
    offset += sprintf(impSignature+offset, "@:");
    
    for (unsigned int i = 2; i < blockSignature.numberOfArguments; ++i)
    {
        offset += sprintf(impSignature+offset, "%s", [blockSignature getArgumentTypeAtIndex: i]);
    }
    
    return impSignature;
}


#pragma mark - OCSquirrelBlockInvocation interface

@interface OCSquirrelBlockInvocation : NSInvocation
@end


#pragma mark - OCSquirrelBlockInvocation implementation

@implementation OCSquirrelBlockInvocation

- (void)dealloc
{
    objc_disposeClassPair(self.class);
}

@end


#pragma mark - NSInvocation+OCSquirrelBlockInvocation implementation

@implementation NSInvocation (OCSquirrelBlockInvocation)

+ (instancetype)squirrelBlockInvocationWithBlock:(id)block
{
    IMP blockImp = imp_implementationWithBlock(block);
    
    if (blockImp == NULL) {
        return nil;
    }
    
    SLBlockDescription *blockDescription = [[SLBlockDescription alloc] initWithBlock: block];
    
    if (blockDescription == nil) {
        return nil;
    }
    
    NSMethodSignature *blockSignature = blockDescription.blockSignature;
    
    char * const impSignatureTypes = BlockMethodSignatureToImpSignature(blockSignature);
    
    NSMethodSignature *impSignature = [NSMethodSignature signatureWithObjCTypes: impSignatureTypes];
    
    if (impSignature == nil) {
        free(impSignatureTypes);
        return nil;
    }
    
    NSMutableString *selectorString = [NSMutableString stringWithString: @"squirrelInvokeBlock"];
    
    for (NSInteger i = 2; i < blockSignature.numberOfArguments; ++i)
    {
        [selectorString appendString: @":"];
    }
    
    SEL selector = NSSelectorFromString(selectorString);
    
    NSString *invocationClassName =
        [NSString stringWithFormat: @"NSInvocation_OCSquirrelBlockInvcation_%lu",
             g_OCSquirrelBlockInvocationIndex++];
    
    Class invocationClass =
    objc_allocateClassPair([OCSquirrelBlockInvocation class],
                           [invocationClassName cStringUsingEncoding: NSASCIIStringEncoding], 0);
    
    objc_registerClassPair(invocationClass);
    
    OCSquirrelBlockInvocationMetadata *metadata =
        [[OCSquirrelBlockInvocationMetadata alloc] initWithBlock: block
                                                             imp: blockImp];
    
    
    NSInvocation *invocation = [invocationClass invocationWithMethodSignature: impSignature];
    class_addMethod(invocationClass, selector, metadata.blockImp, impSignatureTypes);
    
    free(impSignatureTypes);
    
    invocation.selector = selector;
    invocation.target = invocation;
    
    objc_setAssociatedObject(invocation, kAssotiationKeyOCSquirrelBlockInvocationMetadata, metadata, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return invocation;
}

@end
