//
//  NSString+DeleteSpecialCharacters.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 30.07.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "NSString+DeleteSpecialCharacters.h"

@implementation NSString (DeleteSpecialCharacters)

+ (NSString *)deleteSpecialCharatersInString:(NSString *)aString{
    aString = [aString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    aString = [aString stringByReplacingOccurrencesOfString:@"&laquo;" withString:@"\""];
    aString = [aString stringByReplacingOccurrencesOfString:@"&raquo;" withString:@"\""];
    aString = [aString stringByReplacingOccurrencesOfString:@"&mdash;" withString:@" "];
    aString = [aString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@" ," withString:@","];
    aString = [aString stringByReplacingOccurrencesOfString:@" ." withString:@"."];
    aString = [aString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    aString = [aString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    aString = [aString stringByReplacingOccurrencesOfString:@"  " withString:@""];
    return aString;
}
@end
