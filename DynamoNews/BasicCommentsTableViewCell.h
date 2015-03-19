//
//  BasicCommentsTableViewCell.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 18.03.15.
//  Copyright (c) 2015 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicCommentsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentPosition;

@end
