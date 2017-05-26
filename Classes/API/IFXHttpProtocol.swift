//
//  IFXHttpProtocol.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/4/17.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation
import Alamofire

public protocol IFXHttpRequest {
    
    /**
     *  HTTP请求URL
     */
    func getUrl()->String
    /**
     *  验证参数
     */
    func validateParams()->Bool
    
    /**
     *  HTTP Headers
     */
    func getHeaders()->Dictionary<String,String>?;
    
    /**
     *  HTTP Params
     */
    func getParams()->Dictionary<String,Any>?;
    
    /**
     *  HTTP Method
     */
    func getMethod()->HTTPMethod
    
    /**
     *  HTTP 请求超时时间
     *
     *  @return 秒数
     */
    func getTimeoutDuration()->CLong
    
    /**
     *  上传文件列表
     *
     *  @return 文件列表 key：name value：filePath    OR  key:name value:IFXUploadFileInfo
     */
    func getUploadFiles()->Dictionary<String,IFXUploadFileInfo>?;
}

@objc public protocol IFXHttpResponse{
   
    /**
     *  解析响应结果
     *
     *  @param responseData 返回Data
     *
     *  @return 响应对象
     */
    static func parseResult(_ responseData:Data)->IFXHttpResponse;

    /**
     *  是否存在逻辑错误
     */
    @objc optional func isError()->Bool;
    
    /**
     *  服务端返回的逻辑错误码
     */
    @objc optional func errorCode()->String?;
    
    /**
     *  服务端返回的逻辑错误说明
     */
    @objc optional func errorMsg()->String?;
}
