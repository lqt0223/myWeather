//
//  WeatherViewController.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/15.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import UIKit
class WeatherViewController: UIViewController {
    var city = ""
    var weatherJSON:JSON?
    var currentWeather = ""
    @IBOutlet weak var tmpLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.city != ""){
            getWeather()
        }
        tmpLabel.layer.shadowColor = UIColor.lightGray.cgColor
        tmpLabel.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        tmpLabel.layer.shadowRadius = 5.0
        tmpLabel.layer.shadowOpacity = 0.5
        tmpLabel.layer.masksToBounds = false
        tmpLabel.layer.shouldRasterize = true
        
        subLabel.layer.shadowColor = UIColor.lightGray.cgColor
        subLabel.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        subLabel.layer.shadowRadius = 3.0
        subLabel.layer.shadowOpacity = 0.5
        subLabel.layer.masksToBounds = false
        subLabel.layer.shouldRasterize = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControl))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func toggleControl(){
        let viewController = self.parent as! ViewController
        let weatherViewControllers = viewController.childViewControllers as! [WeatherViewController]
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            for weatherViewController in weatherViewControllers{
                weatherViewController.tmpLabel.alpha = 1 - weatherViewController.tmpLabel.alpha
                weatherViewController.subLabel.alpha = 1 - weatherViewController.subLabel.alpha
            }
            viewController.pageControl.alpha = 1 - viewController.pageControl.alpha
            viewController.optionButton.alpha = 1 - viewController.optionButton.alpha
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather(){
        //URLSession Variables
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        let dataParams:[String:Any] = [
            "city":city,
            "key":"8160bb8809f64be09b5fd5d727f41f28"
        ]
        let url = addParamsToURL(url: "https://api.heweather.com/x3/weather", params: dataParams)
        let dataTask = session.dataTask(with: url, completionHandler: {(data:Data?,_,_) in
            self.weatherJSON = JSON(data:data!)["HeWeather data service 3.0"][0]
            // if there is unknown city, show error
            if(self.weatherJSON?["status"].string == "unknown city"){
                DispatchQueue.main.async {
                    let errorView = ErrorView(message: "当前地区暂无天气信息。")
                    errorView.error(atView: self.view)
                }
            }else if(self.weatherJSON?["status"].string != "ok"){
                DispatchQueue.main.async {
                    let errorView = ErrorView(message: "获取天气信息失败。")
                    errorView.error(atView: self.view)
                }
            }else{
                self.displayWeather()
            }
        })
        dataTask.resume()
    }
    func displayWeather() {
        DispatchQueue.main.async {
            self.tmpLabel.text = (self.weatherJSON?["now"]["tmp"].string)! + "°";
            let cityName = self.weatherJSON?["basic"]["city"].string
            let todayCond = self.weatherJSON?["now"]["cond"]["txt"].string
            self.currentWeather = todayCond!
            //bring the currentWeather back to ViewController
            (self.parent as! ViewController).updateBackground()
            
            let todayMinTmp = self.weatherJSON?["daily_forecast"][0]["tmp"]["min"].string
            let todayMaxTmp = self.weatherJSON?["daily_forecast"][0]["tmp"]["max"].string
            let todayTmp = todayMinTmp! + "℃~" + todayMaxTmp! + "℃"
            let pm25 = self.weatherJSON?["aqi"]["city"]["pm25"].string
            let qlty = self.weatherJSON?["aqi"]["city"]["qlty"].string
            
            var subLabelText = cityName! + " / " + todayCond! + "\r" + todayTmp
            
            if (pm25 != nil && qlty != nil) { //for some city, the weather data can be partial. like losing pm25 data
                let airQlty = "PM2.5: " + pm25!// + "(" + qlty! + ")"
                subLabelText += " / " + airQlty
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attrString = NSMutableAttributedString(string: subLabelText)
            attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange.init(location: 0, length: attrString.length))
            self.subLabel.attributedText = attrString
            self.subLabel.font = UIFont(name: "Helvetica", size: 13)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}
