//
//  functions.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/15.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import Foundation

func addParamsToURL(url: String, params: [String:Any]) -> URL{
    var output = url
    output.append("?")
    for param in params{
        let keyName = param.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        output.append(keyName!)
        output.append("=")
        let valueName = ((param.value as AnyObject).description).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) //坑！
        output.append(valueName!)
        output.append("&")
    }
    return URL(string: output)!
}
