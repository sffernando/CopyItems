//
//  NSObject+YYModel.h
//  CPYYModel
//
//  Created by koudai on 2016/12/12.
//  Copyright © 2016年 sojex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide some data-model method:
 
 * Convert json to any object, or convert any object to json.
 * Set object properties with a key-value dictionary (like KVC).
 * Implementations of `NSCoding`, `NSCopying`, `-hash` and `-isEqual:`.
 
 See `YYModel` protocol for custom methods.
 
 
 Sample Code:
 
     ********************** json convertor *********************
     see YYAuthor YYBook YYShadow
 
 */
@interface NSObject (YYModel)

/**
 Creates and returns a new instance of the receiver from a json.
 This method is thread-safe

 @param json  A json object in `NSDictionary`, `NSString` or `NSData`
 @return A new instance created from the json, or nil if an error occurs.
 */
+ (nullable instancetype)yy_modelWithJSON:(id)json;

@end

NS_ASSUME_NONNULL_END
