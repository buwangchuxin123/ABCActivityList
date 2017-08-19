//
//  ActivityModel.h
//  ActivityList
//
//  Created by admin on 2017/7/26.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject
//活动图片的Url字符串。定义属性
@property (strong,nonatomic) NSString *imgUrl;
//活动名称字符串
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *content;
@property (nonatomic) NSInteger like;
@property (nonatomic) NSInteger unlike;
@property(nonatomic) BOOL isFavo;//是否被收藏
-(id)initWithDictionary:(NSDictionary *)dict;
@end
