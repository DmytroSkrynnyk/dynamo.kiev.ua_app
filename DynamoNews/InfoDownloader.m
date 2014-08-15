//
//  InfoDownloader.m
//  DynamoNews
//
//  Created by Aleksandr Ponomarenko on 05.08.14.
//  Copyright (c) 2014 AlPono.inc. All rights reserved.
//

#import "InfoDownloader.h"
#import <AFNetworking.h>
@interface InfoDownloader () {
    AFHTTPRequestOperationManager *manager;
}
@end

static InfoDownloader *downloader = nil;

@implementation InfoDownloader

+ (InfoDownloader *)createDownloaderWithBaseURL:(NSURL *)baseURL {
    if (!downloader) {
        downloader = [[InfoDownloader alloc] initWithURL:baseURL];
    }
    return  downloader;
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:URL];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    return  self;
}

- (void)loadPageWithURL:(NSString *)pagePath gotResponce:(void (^)(id responseObject))success  failure:(void (^)(NSError *error))failure {
    [manager GET:pagePath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)downloadImageByURL:(NSString *)imageLink
               gotResponce:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageLink]
                                                  cachePolicy:NSURLCacheStorageAllowed
                                              timeoutInterval:60];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    dispatch_queue_t backgroundImageDownloading = dispatch_queue_create("com.AlPono.appbackground", NULL);
    [operation setCompletionQueue:backgroundImageDownloading];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [operation start];
}

@end