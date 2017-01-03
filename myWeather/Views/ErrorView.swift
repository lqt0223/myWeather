//
//  ErrorView.swift
//  myWeather
//
//  Created by lqt0223 on 2016/12/16.
//  Copyright © 2016年 lqt0223. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    var message = ""
    init(message : String) {
        super.init(frame: CGRect.zero)
        self.message = message
        self.isUserInteractionEnabled = false
        self.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func error(atView view: UIView){
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Helvetica", size: 12)
        messageLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        messageLabel.sizeToFit()
        self.addSubview(messageLabel)
        self.frame = messageLabel.frame
        self.frame.size = CGSize(width: messageLabel.frame.width + 25.0, height: messageLabel.frame.height + 20.0)
        messageLabel.center = self.center

        self.frame.origin.x = UIScreen.main.bounds.width - self.frame.size.width - 5
        self.frame.origin.y = 20
        view.addSubview(self)
        view.bringSubview(toFront: self)
        self.alpha = 0.0
        UIView.animate(withDuration: 1, animations: {() -> Void in
            self.alpha = 1.0
        })
        UIView.animate(withDuration: 0.5, delay: 3, options: .curveEaseIn, animations: {()->Void in
            self.alpha = 0.0
            self.frame.origin.x += 250.0
        }, completion: {(bool:Bool) -> Void in
            self.removeFromSuperview()
        })
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
