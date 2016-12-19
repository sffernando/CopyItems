//
//  YYModel.h
//  CPYYModel
//
//  Created by koudai on 2016/12/12.
//  Copyright © 2016年 sojex. All rights reserved.
//
//#import <Foundation/Foundation.h>
//
//#if __has_include(<YYModel/YYModel.h>)
//FOUNDATION_EXPORT double YYModelVersionNumber;
//FOUNDATION_EXPORT const unsigned char YYModelVersionString[];
//#import <YYModel/NSObject+YYModel.h>
//#import <YYModel/YYClassInfo.h>
//#else
//#import "NSObject+YYModel.h"
//#import "YYClassInfo.h"
//#endif

#import <Foundation/Foundation.h>

#if __has_include(<CPYYModelSorce/YYModel.h>)
FOUNDATION_EXPORT double YYModelVersionNumber;
FOUNDATION_EXPORT const unsigned char YYModelVersionString[];
#import <CPYYModelSorce/NSObject+YYModel.h>
#import <CPYYModelSorce/YYClassInfo.h>
#else
#import "NSObject+YYModel.h"
#import "YYClassInfo.h"
#endif
