//
//  PopOverData.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation


//MARK: 自定义一个三角形的点
struct TrianglePoint
{
    var p1: CGPoint;
    var p2: CGPoint;
    var p3: CGPoint;
}
//MARK: 气泡的方向
enum PopOverPosition: UInt8 {
    case upper              = 0
    case upperRight         = 1
    case right              = 2
    case lowerRight         = 3
    case lower              = 4
    case lowerLeft          = 5
    case left               = 6
    case upperLeft          = 7
}

//MARK: 气泡路径信息
struct PopPathInfo
{
    var points: [CGPoint] //所需要绘制的点
    var absolute: Bool //是否是绝对路径
    var clockwise: Bool //顺时针
    var size: CGSize
    var popOverIndex: Int
    
    init(points: [CGPoint], absolute: Bool, clockwise: Bool, size: CGSize,popOverIndex: Int) {
        self.points = points
        self.absolute = absolute
        self.clockwise = clockwise
        self.size = size
        self.popOverIndex = popOverIndex
    }
}
