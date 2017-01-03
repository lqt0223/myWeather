//
//  ViewController.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/15.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

// this controller is for updating and managing location info, not for weather updating

import UIKit
import CoreData
import CoreLocation

var cityList:[String] = [] // for managing the view order and contents, current city should be updated into here
var userOption = ["hideWeather": false, "nowOn": 0] as [String : Any]

class ViewController: UIViewController, CLLocationManagerDelegate,UIScrollViewDelegate{
    //locationManager
    var locationManager = CLLocationManager()
    var located = false;

    //other views
    let scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
    let pageControl = UIPageControl()
    let optionButton = UIButton()
    let backgroundView = BackgroundView()
    var weatherReceived = 0
    var weatherParticleViewController = WeatherParticleViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        //the colored background
        backgroundView.frame = CGRect(x: 0, y: 0, width: 654.5, height: 667)
        self.view.addSubview(backgroundView)
        
        // the weather particle system
        self.weatherParticleViewController = self.storyboard?.instantiateViewController(withIdentifier: "WeatherParticleViewController") as! WeatherParticleViewController
        self.view.addSubview(weatherParticleViewController.skView)
        weatherParticleViewController.view.frame = UIScreen.main.bounds
        
        // set the layout
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false

        self.view.addSubview(scrollView)
        self.view.addSubview(pageControl)

        pageControl.isHidden = (pageControl.numberOfPages == 1 ? true:false)
        pageControl.center.x = scrollView.center.x
        pageControl.frame.origin.y = scrollView.frame.maxY - 30.0
        
        // try fetch cityList and userOption data from city.db
        let db = SQLiteDB.sharedInstance
        let cityResults = db.query(sql: "select * from cityList")
        if(cityResults.count == 0){
            cityList = ["上海"]
        }else{
            for result in cityResults{
                cityList.append(result["name"] as! String)
            }
        }
        
        let userOptionResults = db.query(sql: "select * from option")
        if(userOptionResults.count == 0){
            userOption = ["hideWeather": false, "nowOn": 0]
        }else{
            userOption = userOptionResults.first!
            userOption["hideWeather"] = Bool(userOption["hideWeather"] as! String)
        }
    
        //locationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 100.0
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //according to the cityList, generate the WeatherViewController and add to different screens
        var index = 0
        for city in cityList{
            let weatherViewController = self.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
            weatherViewController.city = city
            self.addChildViewController(weatherViewController)
            scrollView.addSubview(weatherViewController.view)
            weatherViewController.view.frame = CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: 500, height: 800) //TODO
            index += 1
        }
        
        setWeatherHidden(option: userOption["hideWeather"] as! Bool)
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(cityList.count), height: scrollView.frame.size.height)
        pageControl.numberOfPages = cityList.count
        pageControl.isHidden = (pageControl.numberOfPages == 1 ? true:false)
        scrollView.contentOffset = CGPoint(x: CGFloat(userOption["nowOn"] as! Int) * UIScreen.main.bounds.width, y: 0)
        pageControl.currentPage = userOption["nowOn"] as! Int
        
        //finally, the option button
        optionButton.setTitle(nil, for: .normal)
        optionButton.setImage(UIImage.init(named:"Gear"), for: .normal)
        optionButton.frame.size = CGSize(width: 30, height: 30)
        optionButton.frame.origin.x = UIScreen.main.bounds.width - optionButton.frame.size.width - 20
        optionButton.frame.origin.y = UIScreen.main.bounds.height - optionButton.frame.size.height - 20
        self.view.addSubview(optionButton)
        optionButton.addTarget(nil, action: #selector(optionButtonPressed), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userOption.updateValue(pageControl.currentPage, forKey: "nowOn")
    }
    
    func updateBackground(){
        weatherReceived += 1
        if(weatherReceived >= cityList.count){
            let currentWeatherViewController = self.childViewControllers[pageControl.currentPage] as! WeatherViewController
            self.backgroundView.currentWeather = currentWeatherViewController.currentWeather
            UIView.transition(with: self.backgroundView, duration: 0.5, options: .transitionCrossDissolve, animations: {()->Void in
                self.backgroundView.setNeedsDisplay()
            }, completion: nil)
        }
    }
    
    func optionButtonPressed(){
        let optionViewController = self.storyboard?.instantiateViewController(withIdentifier: "OptionViewController")
        optionViewController?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(optionViewController!, animated: true, completion:nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //background movement
        let svMaxOffset = scrollView.frame.width * CGFloat(cityList.count - 1)
        if scrollView.contentOffset.x >= 0 &&
            scrollView.contentOffset.x <= svMaxOffset { // when on the first or last screen, disable the backgroundview movement
            let mvMaxOffset = scrollView.frame.width - (backgroundView.frame.width)
            backgroundView.frame.origin.x = (scrollView.contentOffset.x * (mvMaxOffset / svMaxOffset))
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //pageControl
        pageControl.currentPage = abs(Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
        
        //According to the weather on the current city, update the backgroundView
        let currentWeatherViewController = self.childViewControllers[pageControl.currentPage] as! WeatherViewController
        self.backgroundView.currentWeather = currentWeatherViewController.currentWeather
        UIView.transition(with: self.backgroundView, duration: 0.5, options: .transitionCrossDissolve, animations: {()->Void in
            self.backgroundView.setNeedsDisplay()
        }, completion: nil)
        
        //update the particle emittor
        self.weatherParticleViewController.weather = currentWeatherViewController.currentWeather
        self.weatherParticleViewController.setEmittor(weather: self.weatherParticleViewController.weather)
        
    }
    //location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print(error.localizedDescription)
        // set Shanghai as the current city,update weather and give a note
        cityList[0] = "上海"
        let errorView = ErrorView(message: "无法确定您的位置，天气信息可能有误。")
        errorView.error(atView: self.view)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let coordinate = locations.last?.coordinate
        if((coordinate) != nil && located == false){
            getCityName(coordinate: coordinate!)
            located = true
        //if the current city is updated, then refresh the first screen with new city and new weather data. TODO
        }
    }
    
    func getCityName(coordinate: CLLocationCoordinate2D) {
        //URLSession Variables
        var currentCity = ""
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        let dataParams:[String:Any] = [
            "location": coordinate.latitude.description + "," + coordinate.longitude.description,
            "ak": "FPKDtfSA7WBlEmt9lpvEhmfP",
            "output" : "json" ,
            "pois": 1
        ]
        let url = addParamsToURL(url: "http://api.map.baidu.com/geocoder/v2/", params: dataParams)
        let dataTask = session.dataTask(with: url, completionHandler: {(data:Data?,_,_) in
            if(data != nil){
            let json = JSON(data:data!)
            currentCity = json["result"]["addressComponent"]["city"].string!
            //if can't locate a city, show error message
            if(currentCity == ""){
                DispatchQueue.main.async {
                    let errorView = ErrorView(message: "无法确定您所在的城市，天气信息可能有误。")
                    errorView.error(atView:self.view)
                }
                cityList[0] = "上海"
            }else if(currentCity.characters.last == "市"){
                currentCity.remove(at: currentCity.index(before: currentCity.endIndex))
                cityList[0] = currentCity
            }else{
                cityList[0] = currentCity
            }
            //the cityList is updated, ask weatherViewController to update weather
            (self.childViewControllers[0] as! WeatherViewController).getWeather()
            }
        })
        dataTask.resume()
    }
    
    //to add the screen for the new city
    func addNewCity(_ city: String){
        let weatherViewController = self.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
        weatherViewController.city = city
        self.addChildViewController(weatherViewController)
        scrollView.addSubview(weatherViewController.view)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(cityList.count), height: scrollView.frame.size.height)
        pageControl.numberOfPages = cityList.count
        pageControl.isHidden = (pageControl.numberOfPages == 1 ? true:false)
        
        //layout according to the index
        let index = cityList.index(of: city)
        if(index != nil){
            let x = CGFloat(index!) * UIScreen.main.bounds.width
            weatherViewController.view.frame = CGRect(x: x, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
    
    func removeCity(_ index: Int){
        self.childViewControllers[index].view.removeFromSuperview()
        self.childViewControllers[index].removeFromParentViewController()
        if(pageControl.currentPage == index){
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
            pageControl.currentPage = 0
        }
        pageControl.numberOfPages -= 1
        pageControl.isHidden = (pageControl.numberOfPages == 1 ? true:false)
        scrollView.contentSize.width -= UIScreen.main.bounds.width
        // if the city in the middle is deleted, other city pages should move one page forward
        for i in index ..< cityList.count{
            self.childViewControllers[i].view.frame.origin.x -= UIScreen.main.bounds.width
        }
    }

    func jumpTo(index: Int){
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0), animated: true)
        pageControl.currentPage = index
        
        //update the background
        let currentWeatherViewController = self.childViewControllers[index] as! WeatherViewController
        self.backgroundView.currentWeather = currentWeatherViewController.currentWeather
        UIView.transition(with: self.backgroundView, duration: 0.5, options: .transitionCrossDissolve, animations: {()->Void in
            self.backgroundView.setNeedsDisplay()
        }, completion: nil)
        
        //update the particle emittor
        self.weatherParticleViewController.weather = currentWeatherViewController.currentWeather
        self.weatherParticleViewController.setEmittor(weather: self.weatherParticleViewController.weather)
    }
    
    //deprecated
    func setWeatherHidden(option: Bool){
        for weatherViewController in self.childViewControllers{
            weatherViewController.view.isHidden = option
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}
