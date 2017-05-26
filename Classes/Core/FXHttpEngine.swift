//
//  FXHttpEngine.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/25.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation
import ReactiveSwift
import FXLogSwift
import Alamofire

public class FXHttpEngine:IFXHttpEngine{
    
    public var resBlock:FXHttpEngineResponseBlock?
    
    public var nativeResBlock:FXHttpEngineNativeResponseBlock?
    
    public var downloadResBlock:FXHttpEngineDownloadResponseBlock?
    
    public var progressBlock:FXHttpEngineProgressBlock?
    
    public var loading = false//是否在加载中
    
    var sem = DispatchSemaphore.init(value: 1)
    
    var sessionRequest:Alamofire.Request?
    
    var action:ReactiveSwift.Action<Any,Data,NSError>?
    
    var observer:Observer<Data,NSError>?
    
    init() {
        
    }
    
    public func hasLoading() -> Bool {
        return self.loading
    }
    
    /*
     *  上传文件
     */
    func fxRequestUploadFiles(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock,asyn:Bool){
        if request.getUploadFiles() != nil && (request.getUploadFiles()?.count)! > 0 && request.validateParams() && !self.hasLoading() {
            FXLogDebug("HTTP validateParams SUCCESS")
            let url = request.getUrl()
            let params = request.getParams()
            let headers = request.getHeaders()
            let uploadFiles = request.getUploadFiles()
            let method = request.getMethod()
            
            let manager = FXHttpConfig.sharedInstance.defaultSessionManager()
            FXHttpConfig.sharedInstance.setTimeoutDuration(timeoutDuration: request.getTimeoutDuration())
            self.resBlock = resBlock
            self.loading = true
            FXLogDebug("HTTP url:\(String(describing: url)) Params:\(String(describing: params))")
            self.action = ReactiveSwift.Action.init({ (Any) -> SignalProducer<Data, NSError> in
                let signal = SignalProducer<Data,NSError>.init({ (observer, _) in
                    self.observer = observer;
                    manager.upload(multipartFormData: { (multipartFormData) in
                        if params != nil {
                            for key in (params?.keys)! {
                                let value = params![key] ?? ""
                                var data:Data
                                do{
                                    data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
                                }catch{
                                    data = Data.init()
                                }
                                multipartFormData.append(data, withName: key)
                            }
                        }
                        if uploadFiles != nil {
                            let allKeys = uploadFiles?.keys
                            for upkey in allKeys! {
                                let upvalue = uploadFiles?[upkey]
                                if FileManager.default.fileExists(atPath: upvalue!.filePath()) {
                                   multipartFormData.append(URL.init(fileURLWithPath: upvalue!.filePath()), withName: upvalue!.fileName(), fileName: upvalue!.fileName(), mimeType: upvalue!.mimeType())
                                }
                            }
                        }
                    },to: url, method: method, headers: headers, encodingCompletion: { (encodingResult) in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            self.sessionRequest = upload
                            upload.responseData(completionHandler: { (response) in
                                observer.send(value: response.result.value!)
                                observer.sendCompleted()
                            })
                        case .failure(let error):
                            observer.send(error: error as NSError)
                        }
                    })
                })
                return signal
            })
            
            if asyn {
                self.asynExecute(input: 1, responseClass: resClass)
            }else{
                self.synExecute(input: 1, responseClass: resClass)
            }
        }else{
            FXLogError("HTTP validateParams Fail")
            let error = NSError.init(domain: "FXHttpEngineDomain", code: -1, userInfo: [NSLocalizedDescriptionKey:"不符合请求条件"])
            resBlock(nil, error);
        }
    }



    /**
     *  网络请求
     */
    public func fxRequest(request:IFXHttpRequest,responseClass resClass:IFXHttpResponse.Type,responseBlock resBlock:@escaping FXHttpEngineResponseBlock,asyn:Bool){
        if request.validateParams() && !self.hasLoading() {
            FXLogDebug("HTTP validateParams SUCCESS")
            if (request.getUploadFiles()?.count)! > 0 {
                self.asynRequestUploadFiles(request: request, responseClass: resClass, responseBlock: resBlock)
                return
            }
            let method = request.getMethod()
            let url = request.getUrl()
            let params = request.getParams()
            let headers = request.getHeaders()
            
            let manager = FXHttpConfig.sharedInstance.defaultSessionManager()
            FXHttpConfig.sharedInstance.setTimeoutDuration(timeoutDuration: request.getTimeoutDuration())
            
            self.resBlock = resBlock
            self.loading = true
            FXLogDebug("HTTP method:\(String(describing: method)) url:\(String(describing: url)) Params:\(String(describing: params))")
            self.action = ReactiveSwift.Action.init({ (Any) -> SignalProducer<Data, NSError> in
                let signal = SignalProducer<Data,NSError>.init({ (observer, _) in
                    self.observer = observer
                    self.sessionRequest = manager.request(url,method:method, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseData(completionHandler: { (response) in
                        switch response.result {
                        case .success(let value):
                            observer.send(value:value)
                            observer.sendCompleted()
                        case .failure(let error):
                            observer.send(error: error as NSError)
                        }
                    })
                })
                return signal
            })
            if asyn {
                self.asynExecute(input: 1, responseClass: resClass)
            }else{
                self.synExecute(input: 1, responseClass: resClass)
            }
        }else{
            FXLogError("HTTP validateParams Fail")
            let error = NSError.init(domain: "FXHttpEngineDomain", code: -1, userInfo: [NSLocalizedDescriptionKey:"不符合请求条件"])
            resBlock(nil, error);
        }
    }
    
    public func asynRequest(request: IFXHttpRequest, responseClass resClass: IFXHttpResponse.Type, responseBlock resBlock: @escaping FXHttpEngineResponseBlock) {
        FXLogDebug("HTTP Asyn Request")
        self.fxRequest(request: request, responseClass: resClass, responseBlock: resBlock, asyn: true)
    }

    public func synRequest(request: IFXHttpRequest, responseClass resClass: IFXHttpResponse.Type, responseBlock resBlock: @escaping FXHttpEngineResponseBlock) {
        FXLogDebug("HTTP Syn Request")
        self.fxRequest(request: request, responseClass: resClass, responseBlock: resBlock, asyn: false)
    }

    public func asynRequestUploadFiles(request: IFXHttpRequest, responseClass resClass: IFXHttpResponse.Type, responseBlock resBlock: @escaping FXHttpEngineResponseBlock) {
        FXLogDebug("HTTP Asyn RequestUpload")
        self.fxRequestUploadFiles(request: request, responseClass: resClass, responseBlock: resBlock, asyn: true)
    }
    
    public func synRequestUploadFiles(request: IFXHttpRequest, responseClass resClass: IFXHttpResponse.Type, responseBlock resBlock: @escaping FXHttpEngineResponseBlock) {
        FXLogDebug("HTTP Asyn RequestUploa");
        self.fxRequestUploadFiles(request: request, responseClass: resClass, responseBlock: resBlock, asyn: false)
    }

    
    public func asynDownloadByURL(url: String, responseBlock resBlock: @escaping FXHttpEngineDownloadResponseBlock, progress progressBlock: @escaping FXHttpEngineProgressBlock) {
        if self.hasLoading() {
            let error = NSError.init(domain: "FXHttpEngineDomain", code: -1, userInfo: [NSLocalizedDescriptionKey:"网络忙~"])
            resBlock(nil,error)
            return
        }
        
        self.loading = true
        self.progressBlock = progressBlock
        self.downloadResBlock = resBlock
        weak var selfObject = self
        
        let manager = FXHttpConfig.sharedInstance.defaultSessionManager()

        let fileURL = URL.init(string: url)
        let urlRequest = URLRequest.init(url: fileURL!)
        
        //指定下载路径（文件名不变）
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let documentsURL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.sessionRequest = manager.download(urlRequest, to: destination).downloadProgress { (downloadProgress) in
            if selfObject?.progressBlock != nil {
                selfObject?.progressBlock!(downloadProgress.fractionCompleted)
            }
        }.validate().responseJSON { (response) in
            if selfObject?.downloadResBlock != nil {
                if response.error != nil {
                    selfObject?.downloadResBlock!(nil,response.error! as NSError)
                }else{
                    selfObject?.downloadResBlock!(response.temporaryURL?.path,nil)
                }
            }
            selfObject?.downloadResBlock = nil
            selfObject?.progressBlock = nil
            selfObject?.loading = false
        }
    }
    
    /**
     *  异步请求
     */
    func asynExecute(input:Int,responseClass resClass:IFXHttpResponse.Type){
        
        weak var selfObject = self
        
        let signal = self.action?.apply(1)

        signal?.map({ (value) -> IFXHttpResponse in
            return resClass.parseResult(value)
        }).filter({ (response) -> Bool in
            FXLogDebug("HTTP Response Filter~")
            selfObject?.loading = false
            if FXHttpConfig.sharedInstance.httpFilter() != nil {
                return FXHttpConfig.sharedInstance.httpFilter()!.doFilter(res: response)
            }
            return true
        }).startWithResult({ (result) in
            FXLogDebug("HTTP Response SUCCESS~")
            selfObject?.loading = false
            if selfObject?.resBlock != nil {
                selfObject?.resBlock!(result.value,nil)
                selfObject?.resBlock = nil
            }
        })
        
        signal?.startWithFailed({ (error) in
            FXLogDebug("HTTP Response Error:\(error)")
            selfObject?.loading = false
            if selfObject?.resBlock != nil {
                selfObject?.resBlock!(nil,error as NSError)
                selfObject?.resBlock = nil
            }
        })
    }
    
    /*
     *  同步请求
     */
    func synExecute(input:Int,responseClass resClass:IFXHttpResponse.Type){
        weak var selfObject = self
        
        let signal = self.action?.apply(1)
        
        signal?.map({ (value) -> IFXHttpResponse in
            return resClass.parseResult(value)
        }).filter({ (response) -> Bool in
            FXLogDebug("HTTP Response Filter~")
            selfObject?.loading = false
            if FXHttpConfig.sharedInstance.httpFilter() != nil {
                return FXHttpConfig.sharedInstance.httpFilter()!.doFilter(res: response)
            }
            return true
        }).startWithResult({ (result) in
            FXLogDebug("HTTP Response SUCCESS~")
            selfObject?.loading = false
            if selfObject?.resBlock != nil {
                selfObject?.resBlock!(result.value,nil)
                selfObject?.resBlock = nil
            }
            self.sem.signal()//信号+1
        })
        
        signal?.startWithFailed({ (error) in
            FXLogDebug("HTTP Response Error:\(error)")
            selfObject?.loading = false
            if selfObject?.resBlock != nil {
                selfObject?.resBlock!(nil,error as NSError)
                selfObject?.resBlock = nil
            }
            self.sem.signal()//信号+1
        })
        self.sem.wait()//信号-1
        //self.sem.wait(timeout: DispatchTime.distantFuture)
    }
    
    public func cancel() {
        if self.sessionRequest != nil && self.hasLoading() {
            self.sessionRequest?.cancel()
        }
        self.observer?.sendCompleted()
    }
}
