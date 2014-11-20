//
//  StartingViewController.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 20.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

@interface StartingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *internetStatus;

@property (nonatomic) BOOL offline;

@end
