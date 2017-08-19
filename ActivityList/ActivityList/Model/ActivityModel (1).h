//
//  ActivityModel.h
//  ActivityList
//
//  Created by admin on 17/7/26.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject
@property (strong,nonatomic) NSString *imgUrl;//活动图片的Url字符串
@property (strong,nonatomic) NSString *name;//活动名称
@property (strong,nonatomic) NSString *content;//活动内容
@property (nonatomic) NSInteger like;//顶
@property (nonatomic) NSInteger unLike;//踩
@property () BOOL isFavo;//是否被收藏
- (id)initWithDictionary:(NSDictionary *)dict;

@end
