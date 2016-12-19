//
//  YYTestHelper.m
//  CPYYModel
//
//  Created by fernando on 2016/12/19.
//  Copyright © 2016年 sojex. All rights reserved.
//

#import "YYTestHelper.h"

@implementation YYTestHelper

+ (NSString *)jsonStringFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)jsonStringFromObject:(id)object {
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
    return [self jsonStringFromData:data];
}

+ (id)jsonObjectFromData:(NSData *)data {
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
}

+ (id)jsonObjectFromString:(NSString *)string {
    NSData *data = [self jsonDataFromString:string];
    return [self jsonObjectFromData:data];
}

+ (NSData *)jsonDataFromString:(NSString *)string {
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)jsonDataFromObject:(id)object {
    NSString *string = [self jsonStringFromObject:object];
    return [self jsonDataFromString:string];
}

@end
