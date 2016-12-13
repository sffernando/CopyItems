//
//  YYBook.h
//  CPYYModel
//
//  Created by koudai on 2016/12/13.
//  Copyright © 2016年 sojex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSObject+YYModel.h"

@interface YYShadow : NSObject<NSCoding, NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGSize size;

@end

@interface YYAuthor : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSDate *birthday;
@end

@interface YYBook : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger pages;
@property (nonatomic, strong) YYAuthor *author;

@end
