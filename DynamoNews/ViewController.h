//
//  ViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 19.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *img;

@end
