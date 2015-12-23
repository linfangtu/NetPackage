//
//  LHTTPClient.h
//  Lalocal
//
//  Created by LinfangTu on 15/12/21.
//  Copyright © 2015年 LinfangTu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "LLUploadParam.h"

//网络请求类型
typedef NS_ENUM(NSUInteger,NetworkRequestType) {
    NetworkRequestTypePost,
    NetworkRequestTypeGet,
    NetworkRequestTypePut,
    NetworkRequestTypeDelete,
};


typedef void(^ResultBlock)(id responseObject, NSError *error);
typedef void(^DownloadBlock)(NSURLResponse *response, id filepath, NSError *error);
typedef void(^uploadBlock)(NSURLResponse *response, id responseObject, NSError *error);

@interface LHTTPClient : NSObject

+ (LHTTPClient *)sharedClient;


/**
 *  发送网络请求
 *
 *  @param urlString   网址字符串
 *  @param parameters  参数
 *  @param imageData   上传图片参数，只对post有效    
 *  @param type        请求类型
 *  @param resultBlock 返回结果：responseObject,error
 */
- (void)requestWithURLString:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                 uploadParam:(LLUploadParam *)uploadParam
                        type:(NetworkRequestType)type
                 resultBlock:(ResultBlock)resultBlock;

/**
 *  发送下载请求
 *
 *  @param urlString     网址字符串
 *  @param downloadpath  保存地址
 *  @param downloadblock 返回结果：response,filepath,error
 */
- (void)downloadWithrequest:(NSString *)urlString
               downloadpath:(NSString *)downloadpath
              downloadblock:(DownloadBlock)downloadblock;

/**
 *  发送上传请求
 *
 *  @param urlString        服务器地址
 *  @param uploadParam      上传数据
 *  @param uploadblock      返回结果：response,responseObject,error
 */
- (void)uploadWithrequest:(NSString *)urlString
              uploadParam:(LLUploadParam *)uploadParam
              uploadblock:(uploadBlock)uploadblock;




@end
