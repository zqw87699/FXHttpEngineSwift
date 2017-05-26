//
//  IFXUploadFileInfo.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/24.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

public protocol IFXUploadFileInfo{
    /**
     *  文件名称
     */
    func fileName()->String
    
    /**
     *  文件路径
     */
    func filePath()->String
    
    /**
     *  文件内容类型
     */
    func mimeType()->String   
}
