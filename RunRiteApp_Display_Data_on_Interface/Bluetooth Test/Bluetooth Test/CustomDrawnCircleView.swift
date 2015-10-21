//
//  CustomDrawnCircleView.swift
//  Bluetooth Test
//
//  Created by Shuoqi Chen on 10/18/15.
//  Copyright © 2015 Han. All rights reserved.
//

import UIKit
@IBDesignable


class CustomDrawnCircleView: UIButton {

    @IBInspectable var fillColor: UIColor = UIColor.greenColor()
    @IBInspectable var isAddButton: Bool = true

    
    override func drawRect(rect: CGRect) {
        var path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
    }
    
    
    
//    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
//        return UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: CGFloat(1.0)
//        )
//    }
//    
//    view.backgroundColor = UIColorFromRGB(0x209624)

}
