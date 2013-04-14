//
//  OCSquirrelObject.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 14.04.13.
//  Copyright (c) 2013 Egor Chiglintsev. All rights reserved.
//

#import "OCSquirrel.h"


#pragma mark -
#pragma mark OCSquirrelObject interface

@interface OCSquirrelObject : NSObject
{
@protected
    
    /*! ivar backing the squirrelVM property; maintains a strong reference to VM because the
     OCSQuirrelObject cannot actually function without a VM. Note that the OCSquirrelVM itself
     does not track OCSQuirrelObjects or retain any references to them, so no retain cycle here.
     */
    OCSquirrelVM *_squirrelVM;
}

@property (readonly, nonatomic) OCSquirrelVM *squirrelVM;


- (id) initWithVM: (OCSquirrelVM *) squirrelVM;

@end
