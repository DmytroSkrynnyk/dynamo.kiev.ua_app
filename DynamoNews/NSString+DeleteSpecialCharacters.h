//
//  NSString+DeleteSpecialCharacters.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DeleteSpecialCharacters)

+ (NSString *)deleteSpecialCharatersInString:(NSString *)aString;
@end
