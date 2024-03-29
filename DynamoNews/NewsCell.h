//
//  CustomCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 21.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UILabel *publishedDate;
@property (weak, nonatomic) IBOutlet UILabel *commentsCounter;
@property (weak, nonatomic) IBOutlet UIImageView *commentsCounterBackground;

@end
