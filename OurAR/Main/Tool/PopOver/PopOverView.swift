//
//  PopOverView.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation
import UIKit

//MARK: 三角形的气泡
class TriangleRectView: UIView
{
    var fillColor: UIColor = UIColor(red: 223/255, green: 229/255, blue: 237/255, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var pathInfo: PopPathInfo? = nil {
        didSet {
            if let new = pathInfo {
                setNeedsDisplay(CGRect(origin: CGPoint(x: 0, y: 0), size: new.size))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let _ = UIGraphicsGetCurrentContext() else { return }
        let path = UIBezierPath()
        path.lineWidth = 0 // 取消边框
        
        if let pathinfo = pathInfo {
            var step: Int = 0
            for point in pathinfo.points {
                step == 0 ? path.move(to: point) : path.addLine(to: point)
                step += 1
            }
            path.addLine(to: pathinfo.points[0])
        }
        
        path.close()
        
        // 设置填充颜色和绘制
        fillColor.setFill()
        path.fill()
        
    }
}
