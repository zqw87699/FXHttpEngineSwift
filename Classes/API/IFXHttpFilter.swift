//
//  IFXHttpFilter.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

public protocol IFXHttpFilter{
    /**
     *  HTTP 响应结果过滤器
     *
     *  @param res 响应结果
     *
     *  @return YES:返回数据  NO:拦截数据
     */
    func doFilter(res:IFXHttpResponse)->Bool
}
