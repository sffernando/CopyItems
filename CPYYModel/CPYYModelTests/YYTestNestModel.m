//
//  YYTestNestModel.m
//  CPYYModel
//
//  Created by fernando on 2016/12/19.
//  Copyright © 2016年 sojex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YYModel.h"

@interface YYTestNestUser : NSObject
@property uint64_t uid;
@property NSString *name;
@end
@implementation YYTestNestUser
@end

@interface YYTestNestRepo : NSObject
@property uint64_t repoID;
@property NSString *name;
@property YYTestNestUser *user;
@end
@implementation YYTestNestRepo
@end



@interface YYTestNestModel : XCTestCase

@end

@implementation YYTestNestModel

- (void)test {
    NSString *json = @"{\"repoID\":1234,\"name\":\"YYModel\",\"user\":{\"uid\":5678,\"name\":\"ibireme\"}}";
    YYTestNestRepo *repo = [YYTestNestRepo yy_modelWithJSON:json];
    XCTAssert(repo.repoID == 1234);
    XCTAssert([repo.name isEqualToString:@"YYModel"]);
    XCTAssert(repo.user.uid == 5678);
    XCTAssert([repo.user.name isEqualToString:@"ibireme"]);
    
    NSDictionary *jsonObject = [repo yy_modelToJSONObject];
    XCTAssert([((NSString *)jsonObject[@"name"]) isEqualToString:@"YYModel"]);
    XCTAssert([((NSString *)((NSDictionary *)jsonObject[@"user"])[@"name"]) isEqualToString:@"ibireme"]);
    
    [repo yy_modelSetWithJSON:@{@"name" : @"YYImage", @"user" : @{@"name": @"bot"}}];
    XCTAssert(repo.repoID == 1234);
    XCTAssert([repo.name isEqualToString:@"YYImage"]);
    XCTAssert(repo.user.uid == 5678);
    XCTAssert([repo.user.name isEqualToString:@"bot"]);
}

@end
