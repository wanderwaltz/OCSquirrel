//
//  SenTestingKitCompatibility.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 24.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#ifndef OCSquirrel_SenTestingKitCompatibility_h
#define OCSquirrel_SenTestingKitCompatibility_h

/** Converting from SenTestingKit to XCTest was not as straightforward as
 *  one would hope. XCTAssertEqual macro compares its parameters using ==
 *  while STAssertEqual used to compare the encoded NSValues derived from 
 *  the macro parameters. This allowed us to compare C structs directly
 *  for equality which is not possible now using XCTAssertEqual. This broke
 *  a whole lot of our tests since we're often comparing HSQOBJECTs. 
 *
 *  This macro is used to provide STAssertEqual functionality for C structs.
 */

#ifndef XCTAssertEqualStructs
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
#endif // ifndef XCTAssertEqualStructs

#endif
