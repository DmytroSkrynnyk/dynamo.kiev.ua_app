//
//  InfoDownloader.h
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 05.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ASCompletionBlock)(BOOL success, NSDictionary *response, NSError *error);
@interface InfoDownloader : NSObject

+ (InfoDownloader *)createDownloaderWithBaseURL:(NSURL *)baseURL;
- (void)loadPageWithURL:(NSString *)pagePath
            gotResponce:(void (^)(id responseObject))success  failure:(void (^)(NSError *error))failure;

- (void)downloadImageByURL:(NSString *)imageLink
               gotResponce:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure;
@end

