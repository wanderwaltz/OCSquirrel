//
//  AdditionalTestAsserts.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 24.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#ifndef OCSquirrel_AdditionalTestAsserts_h
#define OCSquirrel_AdditionalTestAsserts_h

#define XCTAssertEqualStructs(a1, a2, format...) \
({ \
    @try { \
        __typeof__(a1) a1value = (a1); \
        __typeof__(a2) a2value = (a2); \
        NSValue *a1encoded = [NSValue value:&a1value withObjCType:@encode(__typeof__(a1))]; \
        NSValue *a2encoded = [NSValue value:&a2value withObjCType:@encode(__typeof__(a2))]; \
        if (![a1encoded isEqualToValue:a2encoded]) { \
            _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_Equal, 0, @#a1, @#a2, _XCTDescriptionForValue(a1encoded), _XCTDescriptionForValue(a2encoded)),format); \
        } \
    } \
    @catch (NSException *exception) { \
        _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_Equal, 1, @#a1, @#a2, [exception reason]),format); \
    } \
    @catch (...) { \
        _XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_Equal, 2, @#a1, @#a2),format); \
    } \
})

#endif
