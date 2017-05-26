//
//  FXHttpConfig.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation
import Alamofire

public class FXHttpConfig{
    
    public static let sharedInstance = FXHttpConfig()
    
    var cerSet = Set<Data>.init()
    
    var sessionManager = SessionManager.init()
    
    var defaultTimeoutDuration = 60
    
    var filter:IFXHttpFilter?
    
    var allowInvalidCertificates = false
    
    init() {
        self.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
            var credential: URLCredential?
            
            if self.allowInvalidCertificates {
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                    credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                } else {
                    if challenge.previousFailureCount > 0 {
                        disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
                    } else {
                        credential = self.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                        if credential != nil {
                            disposition = URLSession.AuthChallengeDisposition.useCredential
                        }
                    }
                }
            }else{
                let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
                
                var pass = false
                for cerData in self.cerSet {
                    if remoteCertificateData.isEqual(cerData) == true {
                        pass = true
                        disposition = URLSession.AuthChallengeDisposition.useCredential
                        credential = URLCredential(trust: serverTrust)
                        break
                    }
                }
                if pass == false {
                    disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
                }
            }
            return (disposition, credential)
        }
    }
    /*
     *  默认请求任务
     */
    public func defaultSessionManager()->SessionManager{
        return self.sessionManager
    }
    /*
     *  过滤器
     */
    public func httpFilter()->IFXHttpFilter?{
        return self.filter
    }
    /**
     *  设置超时时间
     *  Default：60
     */
    public func setTimeoutDuration(timeoutDuration:CLong){
        if timeoutDuration > 0 {
            self.sessionManager.session.configuration.timeoutIntervalForRequest = TimeInterval(timeoutDuration)
        }else{
            self.sessionManager.session.configuration.timeoutIntervalForRequest = TimeInterval(self.defaultTimeoutDuration)
        }
    }
    /**
     *  是否允许无效证书
     *  Default：NO
     */
    public func setAllowInvalidCertificates(allow:Bool){
        self.allowInvalidCertificates = allow
    }
    /**
     *  最大并发数(default 5)
     */
    public func setMaxConcurrentCount(concurrentCount:Int){
        
    }
    /**
     *  添加过滤器
     */
    public func addFilter(filter:IFXHttpFilter){
        self.filter = filter
    }
    /**
     *  添加证书(只可以添加cer证书)
     */
    public func addCertificater(path:String){
        if FileManager.default.fileExists(atPath: path) && path.components(separatedBy: ".").last == "cer"{
            do{
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path), options: Data.ReadingOptions.alwaysMapped)
                self.cerSet.insert(data)
            }catch{
                print("获取证书数据失败\(path)")
            }
        }
    }
}
