//
//  ArticlesTableViewCell.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 31.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "ArticlesTableViewCell.h"

@implementation ArticlesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
