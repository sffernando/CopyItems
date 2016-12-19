//
//  YYTestHelper.h
//  CPYYModel
//
//  Created by fernando on 2016/12/19.
//  Copyright © 2016年 sojex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYTestHelper : NSObject
+ (NSString *)jsonStringFromData:(NSData *)data;
+ (NSString *)jsonStringFromObject:(id)object;
+ (id)jsonObjectFromData:(NSData *)data;
+ (id)jsonObjectFromString:(NSString *)string;
+ (NSData *)jsonDataFromString:(NSString *)string;
+ (NSData *)jsonDataFromObject:(id)object;
@end
