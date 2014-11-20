//
//  ArticlesTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 31.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticlesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *publishedDate;
@property (weak, nonatomic) IBOutlet UILabel *title;
@end
