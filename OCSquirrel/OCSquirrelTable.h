//
//  OCSquirrelTable.h
//  OCSquirrel
//
//  Created by Egor Chiglintsev on 25.05.14.
//  Copyright (c) 2014 Egor Chiglintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSquirrelObject.h"

@class OCSquirrelVM;


#pragma mark - <OCSquirrelTable> protocol

/** Interface for working with Squirrel tables.
 *
 *  A table is an associative key-value container heavily used in Squirrel. Each Squirrel VM has
 *  a root table which contains top-level functions and global data.
 *
 *  OCSquirrelTable protocol provides interface very similar to NSMutableDictionary, complementing
 *  it with type-specific accessor methods.
 *
 *  Each key-value pair in OCSquirrelTable is referred to as 'slot'.
 *
 *  @note Unlike `NSDictionary` Squirrel tables can contain `null` values which are represented by
 *  either `nil` or `NSNull` values in OCSquirrel API.
 *
 */
@protocol OCSquirrelTable<NSObject, OCSquirrelObject>
@required
/** @name Properties */

/** Returns number of slots (key-value pairs) in the receiver.
 *
 *  @note This count includes possible `null` values stored in the table. removeObjectForKey: decreases
 *    count if the key existed in the table.
 */
- (NSUInteger)count;


/** @name Getter methods */

/** Reads `SQInteger` value for a given key.
 *
 *  @param key A key for which to return the corresponding `SQInteger`.
 *
 *  @return Integer value for the given key. If the value for the given key is not of an integer
 *    type or there is no such key in the table, returns 0.
 */
- (SQInteger)integerForKey:(id)key;


/** Reads `SQFloat` value for a given key.
 *
 *  @param key A key for which to return the corresponding `SQFloat`.
 *
 *  @return Float value for the given key. If the value for the given key is not of a float
 *    type or there is no such key in the table, returns 0.0.
 */
- (SQFloat)floatForKey:(id)key;


/** Reads `BOOL` value for a given key.
 *
 *  @param key A key for which to return the corresponding `BOOL`.
 *
 *  @return `BOOL` value for the given key. If the value for the given key is not of a boolean
 *    type or there is no such key in the table, returns NO.
 */
- (BOOL)boolForKey:(id)key;


/** Reads `NSString` value for a given key.
 *
 *  @param key A key for which to return the corresponding `NSString`.
 *
 *  @return `NSString` value for the given key. If the value for the given key is not of a string
 *    type or there is no such key in the table, returns `nil`.
 */
- (NSString *)stringForKey:(id)key;


/** Reads `SQUserPointer` value for a given key.
 *
 *  @param key A key for which to return the corresponding `SQUserPointer`.
 *
 *  @return `SQUserPointer` value for the given key. If the value for the given key is not of a user pointer
 *    type or there is no such key in the table, returns `NULL`.
 */
- (SQUserPointer)userPointerForKey:(id)key;


/** Reads an Objective-C value for a given key.
 *
 *  @param key A key for which to return the corresponding Objective-C object.
 *
 *  @return Objective-C value read. Applies automatic boxing/type conversion rules as per OCSquirrelVMStack protocol.
 *    If there is no such key in the table, returns `nil`.
 *
 */
- (id)objectForKey:(id)key;


/** Reads an Objective-C value for a given key.
 *
 *  @param key A key for which to return the corresponding Objective-C object.
 *
 *  @discussion Alias for objectForKey: method to allow square bracket syntax. `NSCopying` requirement is added
 *    for selector compatibility with `NSDictionary`.
 */
- (id)objectForKeyedSubscript:(id<NSCopying>)key;


#pragma mark setter methods
/** @name Setter methods */


/** Sets a given Objective-C object for a given key.
 *
 *  @param object Object to set for the given key. May be `nil`.
 *  @param key Key with which to store the object.
 *
 *  @discussion Applies automatic boxing/type conversion rules as per OCSquirrelVMStack protocol.
 *
 */
- (void)setObject:(id)object forKey:(id)key;


/** Sets a given Objective-C object for a given key.
 *
 *  @param object Object to set for the given key. May be `nil`.
 *  @param key Key with which to store the object.
 *
 *  @discussion Alias for setObject:forKey: method to allow square bracket syntax. `NSCopying` requirement is added
 *    for selector compatibility with `NSMutableDictionary`.
 */
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;


/** Sets `SQInteger` value for a given key.
 *
 *  @param value `SQInteger` to store in the table.
 *  @param key Key with which to store the value.
 */
- (void)setInteger:(SQInteger)value forKey:(id)key;


/** Sets `SQFloat` value for a given key.
 *
 *  @param value `SQFloat` to store in the table.
 *  @param key Key with which to store the value.
 */
- (void)setFloat:(SQFloat)value forKey:(id)key;


/** Sets `BOOL` value for a given key.
 *
 *  @param value `BOOL` to store in the table.
 *  @param key Key with which to store the value.
 */
- (void)setBool:(BOOL)value forKey:(id)key;


/** Sets `NSString` value for a given key.
 *
 *  @param value `NSString` to store in the table.
 *  @param key Key with which to store the value.
 */
- (void)setString:(NSString *)value forKey:(id)key;


/** Sets `SQUserPointer` value for a given key.
 *
 *  @param pointer `SQUserPointer` to store in the table.
 *  @param key Key with which to store the value.
 */
- (void)setUserPointer:(SQUserPointer)pointer forKey:(id)key;


/** Removes the slot with a given key from the table.
 *
 *  @param key Key of the slot to remove.
 *
 *  @discussion If the table contains a slot with the given key, this slot is removed and `count` property
 *    value decreases as the result.
 */
- (void)removeObjectForKey:(id)key;


#pragma mark enumeration
/** @name Enumeration */


/** `NSEnumerator` for the keys of the table.
 */
- (NSEnumerator *)keyEnumerator;


/** Applies a given block object to the entries of the dictionary.
 *
 *  @param block A block object to operate on entries in the dictionary.
 *
 *  @discussion If the `block` sets `*stop` to `YES`, the enumeration stops.
 */
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id value, BOOL *stop))block;


#pragma mark calls
/** @name Closure calls */

/** Calls a Squirrel closure for a given key with no parameters.
 *
 *  @param key A key for which to read the Squirrel closure to be called.
 *
 *  @return Return value of the Squirrel closure call. If the key is not found in the table or the value
 *    for the given key is not a Squirrel closure, returns `nil`. The return value is boxed/converted as
 *    necessary per OCSquirrelVMStack protocol.
 *
 *  @discussion Takes a value for a given key expecting it to be a Squirrel closure. Uses self as an envoronment
 *    object passed as an implicit `this` param to the Squirrel closure call.
 */
- (id)callClosureWithKey:(id)key;


/** Calls a Squirrel closure for a given key with parameters provided.
 *
 *  @param key A key for which to read the Squirrel closure to be called.
 *  @param parameters Parameters of the Squirrel closure boxed into `NSArray` as per OCSquirrelVMStack protocol.
 *
 *  @return Return value of the Squirrel closure call. If the key is not found in the table or the value
 *    for the given key is not a Squirrel closure, returns `nil`. The return value is boxed/converted as
 *    necessary per OCSquirrelVMStack protocol.
 *
 *  @discussion Takes a value for a given key expecting it to be a Squirrel closure. Uses self as an envoronment
 *    object passed as an implicit `this` param to the Squirrel closure call.
 */
- (id)callClosureWithKey:(id)key
              parameters:(NSArray *)parameters;

@end




#pragma mark - OCSquirrelTable interface

/** Default implementation of OCSquirrelTable protocol.
 *
 *  @note This class is integrated into `NSMutableDictionary` cluster and therefore provides almost all of 
 *    the mutable dictionary APIs unless specifically marked as unavailable. Note that the initializer methods
 *    inherited from `NSDictionary` class will associate OCSquirrelTable with the default Squirrel VM provided
 *    by [OCSquirrelVM defaultVM].
 */
@interface OCSquirrelTable : NSMutableDictionary<OCSquirrelTable>
/** @name Initialization methods */

/** Initializes an empty OCSquirrelTable with a given Squirrel VM.
 *
 *  @param vm OCSquirrelVM to be associated with the table. Cannot be `nil`.
 *
 *  @exception NSInvalidArgumentException Is thrown when trying to initialize with `nil` OCSquirrelVM.
 */
- (instancetype)initWithVM:(OCSquirrelVM *)vm;


/** Initializes a newly allocated OCSquirrelTable with count entries.
 *
 *  @param vm OCSquirrelVM to be associated with the table. Cannot be `nil`.
 *
 *  @param objects A C array of values for the new dictionary.
 *
 *  @param keys A C array of keys for the new dictionary.
 *
 *  @param count The number of elements to use from the keys and objects arrays. count must not exceed
 *   the number of elements in objects or keys.
 *
 *
 *  @discussion This method steps through the objects and keys arrays, creating entries in the new 
 *    OCSquirrelTable as it goes.
 *
 *  @exception NSInvalidArgumentException Is thrown when trying to initialize with `nil` OCSquirrelVM.
 */
- (instancetype)initWithSquirrelVM:(OCSquirrelVM *)vm
                           objects:(const id [])objects
                           forKeys:(const id<NSCopying> [])keys
                             count:(NSUInteger)count;

#pragma mark unavailable NSDictionary methods

+ (instancetype)dictionary __unavailable;
+ (instancetype)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key __unavailable;
+ (instancetype)dictionaryWithObjects:(const id [])objects
                              forKeys:(const id <NSCopying> [])keys
                                count:(NSUInteger)cnt __unavailable;
+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... __unavailable;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dict __unavailable;
+ (instancetype)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys __unavailable;

+ (id)dictionaryWithContentsOfFile:(NSString *)path __unavailable;
+ (id)dictionaryWithContentsOfURL:(NSURL *)url __unavailable;
- (id)initWithContentsOfFile:(NSString *)path __unavailable;
- (id)initWithContentsOfURL:(NSURL *)url __unavailable;


@end