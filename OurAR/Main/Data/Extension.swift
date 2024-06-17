//
//  Extension.swift
//  OurAR
//
//  Created by lee on 2023/8/29.
//

import Foundation
import UIKit


extension Date
{
    //秒级
    var timeStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return Int(timeInterval)
    }
}

extension UIColor {
    
    static func hex(_ val: UInt) -> UIColor {
            var r: UInt = 0, g: UInt = 0, b: UInt = 0;
            var a: UInt = 0xFF
            var rgb = val

            if (val & 0xFFFF0000) == 0 {
                a = 0xF

                if val & 0xF000 > 0 {
                    a = val & 0xF
                    rgb = val >> 4
                }

                r = (rgb & 0xF00) >> 8
                r = (r << 4) | r

                g = (rgb & 0xF0) >> 4
                g = (g << 4) | g

                b = rgb & 0xF
                b = (b << 4) | b

                a = (a << 4) | a

            } else {
                if val & 0xFF000000 > 0 {
                    a = val & 0xFF
                    rgb = val >> 8
                }

                r = (rgb & 0xFF0000) >> 16
                g = (rgb & 0xFF00) >> 8
                b = rgb & 0xFF
            }

            //NSLog("r:%X g:%X b:%X a:%X", r, g, b, a)

            return UIColor(red: CGFloat(r) / 255.0,
                           green: CGFloat(g) / 255.0,
                           blue: CGFloat(b) / 255.0,
                           alpha: CGFloat(a) / 255.0)
        }
}

extension UIImage {
    static func render(size: CGSize, _ draw: () -> Void) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        draw()
        
        return UIGraphicsGetImageFromCurrentImageContext()?
            .withRenderingMode(.alwaysTemplate)
    }
    
    static func make(size: CGSize, color: UIColor = .white) -> UIImage? {
        return render(size: size) {
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
        }
    }
}
