//
//  ActivityTableViwCell.h
//  ActivityList
//
//  Created by admin on 17/7/25.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViwCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityName;
@property (weak, nonatomic) IBOutlet UILabel *activityLike;
@property (weak, nonatomic) IBOutlet UILabel *activityUnlike;
@property (weak, nonatomic) IBOutlet UILabel *activityContent;
@property (weak, nonatomic) IBOutlet UIButton *favoBtn;

@end
