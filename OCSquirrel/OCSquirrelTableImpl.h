//
//  OCSquirrelTableImpl.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrelObjectImpl.h"
#import "OCSquirrelTable.h"


#pragma mark -
#pragma mark OCSquirrelTableImpl interface

/** Internal implementation of OCSquirrelTable protocol.
 */
@interface OCSquirrelTableImpl : OCSquirrelObjectImpl<OCSquirrelTable>

+ (instancetype)rootTableForVM:(OCSquirrelVM *)squirrelVM;
+ (instancetype)registryTableForVM:(OCSquirrelVM *)squirrelVM;

@end



/** `NSEnumerator` subclass which is used to enumerate keys of a certain `OCSquirrelTable`
 */
@interface OCSquirrelTableKeyEnumerator : NSEnumerator

/** Initializes the enumerator with a given `OCSquirrelTableImpl`.
 *
 *  @param impl `OCSquirrelTableImpl` to be used for key enumeration.
 *
 *  @return `OCSquirrelTableKeyEnumerator` suitable to enumerate keys of the given table.
 */
- (instancetype)initWithTableImpl:(OCSquirrelTableImpl *)impl;

@end