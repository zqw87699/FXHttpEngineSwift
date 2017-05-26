//
//  IFXHttpEngine.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

/**
 *  回调block
 *
 *  @param res   http response
 *  @param error error
 */
public typealias FXHttpEngineResponseBlock = (_ res:IFXHttpResponse?,_ error:NSError?)->Void

/**
 *  响应block
 */
public typealias FXHttpEngineNativeResponseBlock = (_ resData:Data?,_ error:NSError?)->Void

/**
 *  下载响应block
 *
 *  @param filePath 下载文件名
 *  @param error    错误
 */
public typealias FXHttpEngineDownloadResponseBlock = (_ filePath:String?,_ error:NSError?)->Void

/**
 *  进度条
 *
 *  @param progress 进度（0.0f~1.0f）
 */
public typealias FXHttpEngineProgressBlock = (_ progress:Double)->Void

public protocol IFXHttpEngine {
    
    /**
     *  是否在请求中
     */
    func hasLoading()->Bool;
    /**
     *  异步请求
     *
     *  @param request  http request
     *  @param resClass http response Class
     *  @param resBlock response block
     */
    func asynRequest(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock)
    
    /**
     *  同步请求(使用dispatch_semaphore_t阻塞达到同步效果,不要在主线程调用)
     *
     *  @param request  http request
     *  @param resClass http response Class
     *  @param resBlock response block
     */
    func synRequest(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock)
    /**
     *  异步请求(上传文件)
     *
     *  @param request  http request
     *  @param resClass http response Class
     *  @param resBlock response block
     */
    func asynRequestUploadFiles(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock)
    
    /**
     *  同步请求(上传文件)(使用dispatch_semaphore_t阻塞达到同步效果,不要在主线程调用)
     *
     *  @param request  http request
     *  @param resClass http response Class
     *  @param resBlock response block
     */
    func synRequestUploadFiles(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock)
    /**
     *  异步下载
     *
     *  @param url           下载文件url
     *  @param resBlock      响应block
     *  @param progressBlock 下载进度block
     */
    func asynDownloadByURL(url:String,responseBlock resBlock:@escaping FXHttpEngineDownloadResponseBlock,progress progressBlock:@escaping FXHttpEngineProgressBlock)
    /**
     *  取消任务
     */
    func cancel()
}
