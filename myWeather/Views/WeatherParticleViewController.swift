//
//  WeatherParticleViewController.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/25.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import UIKit
import SpriteKit

class WeatherParticleViewController: UIViewController {
    let scene = SKScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var skView: SKView {
        return view as! SKView
    }
    var emittor: SKEmitterNode? = nil
    var weather = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = SKView()
        view.backgroundColor = UIColor.clear
        scene.backgroundColor = UIColor.clear

        self.emittor = SKEmitterNode(fileNamed: "rain.sks")
        self.setEmittor(weather: self.weather)
        emittor?.position = CGPoint(x: 0, y: 667)
        scene.addChild(emittor!)
    }
    override func viewWillAppear(_ animated: Bool) {
        skView.presentScene(scene)
    }
    
    func setEmittor(weather:String) {
        if(weather.contains("雨")){
            self.emittor?.particleTexture = SKTexture(imageNamed: "rain")
            self.emittor?.particleBirthRate = 500
            self.emittor?.particleLifetime = 1
            self.emittor?.particleSpeed = -800
            self.emittor?.particleSpeedRange = -1000
            self.emittor?.yAcceleration = -100
            self.emittor?.particleScaleRange = 0.05
            
        }else if(weather.contains("雪")){
            self.emittor?.particleTexture = SKTexture(imageNamed: "snow")
            self.emittor?.particleBirthRate = 500
            self.emittor?.particleLifetime = 20
            self.emittor?.particleSpeed = -10
            self.emittor?.particleSpeedRange = -50
            self.emittor?.yAcceleration = -100
            self.emittor?.particleScaleRange = 1
        }else{
            self.emittor?.particleBirthRate = 0
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
