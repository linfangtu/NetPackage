//
//  LHTTPClient.m
//  Lalocal
//
//  Created by LinfangTu on 15/12/21.
//  Copyright © 2015年 LinfangTu. All rights reserved.
//

#import "LHTTPClient.h"
#import "AFNetworking.h"

@interface LHTTPClient ()
@property (nonatomic, assign, getter=isConnected) BOOL connected;/**<网络是否连接*/

@end

@implementation LHTTPClient


+ (LHTTPClient *)sharedClient {
    
    static LHTTPClient *sharedClient = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

/**
 *  检测网络状态
 */
- (BOOL)isConnected {
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

- (void)requestWithURLString:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                 uploadParam:(LLUploadParam *)uploadParam
                        type:(NetworkRequestType)type
                 resultBlock:(ResultBlock)resultBlock {
    
    if (!self.isConnected) {
        NSLog(@"没有网络,建议在手机设置中打开网络");
        return;
    }
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    switch (type) {
        case NetworkRequestTypePost: {
            [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                if (uploadParam != nil) {
                    [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];
                }

            } progress:^(NSProgress * _Nonnull uploadProgress) {
                // This is not called back on the main queue.
                // You are responsible for dispatching to the main queue for UI updates
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update the progress view
                    
                });
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (resultBlock) {
                    resultBlock(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (resultBlock) {
                    resultBlock(task, error);
                }
            }];
            break;
        }
        case NetworkRequestTypeGet: {
            [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                // This is not called back on the main queue.
                // You are responsible for dispatching to the main queue for UI updates
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Update the progress view

                });

            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (resultBlock) {
                    resultBlock(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (resultBlock) {
                    resultBlock(task, error);
                }
            }];
            break;
        }
        case NetworkRequestTypePut: {
            [manager PUT:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (resultBlock) {
                    resultBlock(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (resultBlock) {
                    resultBlock(task, error);
                }
            }];
            break;
        }
        case NetworkRequestTypeDelete: {
            [manager DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (resultBlock) {
                    resultBlock(responseObject, nil);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (resultBlock) {
                    resultBlock(task, error);
                }
            }];
            break;
        }
        default:
            break;
    }

}


- (void)downloadWithrequest:(NSString *)urlString
               downloadpath:(NSString *)downloadpath
              downloadblock:(DownloadBlock)downloadblock {
    if (!self.isConnected) {
        NSLog(@"没有网络,建议在手机设置中打开网络");
        return;
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        downloadblock(response, filePath, error);
    }];
    
   
    [downloadTask resume];
    
    
}

- (void)uploadWithrequest:(NSString *)urlString
              uploadParam:(LLUploadParam *)uploadParam
              uploadblock:(uploadBlock)uploadblock {
    if (!self.isConnected) {
        NSLog(@"没有网络,建议在手机设置中打开网络");
        return;
    }

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];

    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            
        });

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        uploadblock(response, responseObject, error);

        
    }];
    
    [uploadTask resume];
}



@end
