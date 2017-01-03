//
//  ColorFilter.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/18.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    let midnightColor = [#colorLiteral(red: 0.2078431373, green: 0.1607843137, blue: 1, alpha: 1).cgColor,#colorLiteral(red: 0.05490196078, green: 0.8117647059, blue: 0.5058823529, alpha: 1).cgColor]
    let middayColor = [#colorLiteral(red: 1, green: 0.7019607843, blue: 0, alpha: 1).cgColor,#colorLiteral(red: 0.1254901961, green: 0.5215686275, blue: 0.8196078431, alpha: 1).cgColor]
    let warmTone = #colorLiteral(red: 1, green: 0.4161762919, blue: 0.122577567, alpha: 1).cgColor
    let darkTone = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1).cgColor
    var currentWeather = ""
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let uiImage = UIImage(named: "background")
        uiImage?.draw(in: CGRect(x: 0, y: 0, width: 654.5, height: 667))
        ctx?.setBlendMode(.overlay)
        let localDate = Date()
        //the gradient to give a sense of time
        let gradient = getColorGradient(localDate: localDate)
        //the gradient to make the top darker and bottom lighter
        let beginColor2 = UIColor.black.cgColor
        let endColor2 = UIColor.white.cgColor
        let colorArray2 = [beginColor2,endColor2] as CFArray
        let gradient2 = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorArray2, locations: nil)
        
        //the layer to make sunrise and sunset time
        let cal = NSCalendar.current
        let components = cal.dateComponents(in: TimeZone.current, from: localDate)
        let hour = Double(components.hour!)
        let minute = Double(components.minute!) / 60
        let warmAlpha = -0.5 * sin((hour + minute)/1.5 - 0.5)  + 0.5 //Math is important!
        var warmToneComponents = warmTone.components
        warmToneComponents?[3] = CGFloat(warmAlpha)
        let warmColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: warmToneComponents!)
        //the layer to make night darker
        
//        let darkAlpha = 0.5 * sin((hour + minute)/4 + 0.5)  + 0.5 //Math is important!
//        var darkToneComponents = darkTone.components
//        darkToneComponents?[3] = CGFloat(darkAlpha)
//        let darkColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: darkToneComponents!)
        
        //the layer to indicate weather
        let weatherColor = getWeatherColor(weather: currentWeather)

        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: 0, y: UIScreen.main.bounds.height)
        
        ctx?.saveGState()
        ctx?.addRect(CGRect(x: 0, y: 0, width: 654.5, height: 667))
        ctx?.clip()
        ctx?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))//gradient1
//        ctx?.addRect(CGRect(x: 0, y: 0, width: 654.5, height: 667))
//        ctx?.clip()
//        ctx?.drawLinearGradient(gradient2!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))//gradient2
        ctx?.setFillColor(warmColor!)
        ctx?.fill(CGRect(x: 0, y: 0, width: 654.5, height: 667))//warm layer
        ctx?.setBlendMode(weatherColor.blendMode)
        ctx?.setFillColor(weatherColor.color)
        ctx?.fill(CGRect(x: 0, y: 0, width: 654.5, height: 667))//weather layer
        ctx?.restoreGState()
    }
    
    func getWeatherColor(weather: String) -> (color:CGColor, blendMode:CGBlendMode) {
        if(weather.contains("晴")){
            return (#colorLiteral(red: 1, green: 0.6705882353, blue: 0.4235294118, alpha: 1).cgColor, CGBlendMode.softLight)
        }else if(weather.contains("雪")){
            return (#colorLiteral(red: 0.04229647666, green: 0.0815544948, blue: 0.09642285854, alpha: 1).cgColor, CGBlendMode.hue)
        }else if(weather.contains("雨")){
            return (#colorLiteral(red: 0.8470588235, green: 1, blue: 0.8823529412, alpha: 1).cgColor, CGBlendMode.color)
        }else if(weather.contains("云")){
            return (#colorLiteral(red: 0.2196078431, green: 0.6, blue: 0.537254902, alpha: 1).cgColor, CGBlendMode.softLight)
        }else if(weather.contains("雾") || weather.contains("霾")){
            return (#colorLiteral(red: 0.7336427569, green: 0.7336601615, blue: 0.733650744, alpha: 1).cgColor, CGBlendMode.hardLight)
        }else{
            return (#colorLiteral(red: 0.7336427569, green: 0.7336601615, blue: 0.733650744, alpha: 0).cgColor, CGBlendMode.normal)
        }
    }
    
    func getColorGradient(localDate: Date) -> CGGradient{
        let cal = NSCalendar.current
        let components = cal.dateComponents(in: TimeZone.current, from: localDate)
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        var startColor: CGColor?
        var endColor: CGColor?
        
        var percentage = 0.0
        if(hour! <= 14){ // midnight -> midday
            var mnItvl = -60 * 60 * (hour! - 2)
            mnItvl -= 60 * minute!
            mnItvl -= second!
            let midnightDate = Date(timeIntervalSinceNow: TimeInterval(mnItvl))
            percentage = (localDate.timeIntervalSince(midnightDate)) / TimeInterval(12*60*60)
            startColor = getAverageColor(color1: midnightColor[0], color2: middayColor[0], percentage: percentage)
            endColor = getAverageColor(color1: midnightColor[1], color2: middayColor[1], percentage: percentage)
        }else{  // midday -> midnight
            var mdItvl = -60 * 60 * (14 - hour!)
            mdItvl -= 60 * minute!
            mdItvl -= second!
            let middayDate = Date(timeIntervalSinceNow: TimeInterval(mdItvl))
            percentage = -(localDate.timeIntervalSince(middayDate)) / TimeInterval(12*60*60)
            startColor = getAverageColor(color1: middayColor[0], color2: midnightColor[0], percentage: percentage)
            endColor = getAverageColor(color1: middayColor[1], color2: midnightColor[1], percentage: percentage)
        }
        let colorArray = [startColor,endColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colorArray, locations: nil)
        return gradient!
        
    }
    
    func getAverageColor(color1: CGColor, color2: CGColor, percentage: Double) -> CGColor{
        var avrColorComponents:[CGFloat] = []
        for i in 0..<4{
            let avrValue = ((color2.components?[i])! - (color1.components?[i])!) * CGFloat(percentage) + (color1.components?[i])!
            avrColorComponents.append(avrValue)
        }
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: avrColorComponents)!
    }
}
