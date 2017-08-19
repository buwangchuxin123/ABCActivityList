//
//  ActivityModel.m
//  ActivityList
//
//  Created by admin on 2017/7/26.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel
-(id)initWithDictionary:(NSDictionary *)dict{
    self =[super init];
    //判断活动图片是否为空值
    if(self){
    self.imgUrl=[dict[@"imgUrl"]isKindOfClass:[NSNull class]]?@"":dict[@"imgUrl"];
    self.name=[dict[@"name"] isKindOfClass:[NSNull class]]?@"活动":dict[@"name"];
    self.content=[dict[@"content"] isKindOfClass:[NSNull class]]?@"暂无内容":dict[@"content"];
    self.like=[dict[@"like"] isKindOfClass:[NSNull class]]?0:[dict[@"like"] integerValue];
    self.unlike=[dict[@"unReliableNumber"] isKindOfClass:[NSNull class]]?0:[dict[@"unReliableNumber"] integerValue];
        self.isFavo =[dict[@"isFavo"]isKindOfClass:[NSNull class]]?NO:[dict[@"isFavo"]boolValue];
    }
    return self;
    }

@end
