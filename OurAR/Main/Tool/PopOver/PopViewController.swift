//
//  PopViewController.swift
//  OurAR
//
//  Created by lee on 2023/8/23.
//

import Foundation
import UIKit

class PopViewController: UIViewController
{
    var triangleView: TriangleRectView! //气泡层
    var innerViewSize: CGSize! //内部视图的大小
    var pad: CGFloat = 10 //气泡距targetView Center的距离
    var triLen: CGFloat { //气泡直角三角形的斜边长度
        get {
            return 20
        }
    }
    var triangleOff: CGFloat { //实际的绘制的triangle rect view的长宽都要大一点
        get {
            return triLen / 2
        }
    }
    var triangleSize: CGSize {
        get {
            return CGSize(width: innerViewSize.width + triangleOff * 2, height: innerViewSize.height + triangleOff * 2)
        }
    }
    //指向的目标视图
    var targetView: UIView? = nil {
        didSet {
            if let target = targetView {
                var superView: UIView? = target.superview
                var childView: UIView = target
                var point:CGPoint = CGPoint(x: target.bounds.origin.x + target.bounds.width / 2, y: target.bounds.origin.y + target.bounds.height / 2)
                while let superV = superView {
                    point = childView.convert(point, to: superV)
                    superView = superV.superview
                    childView = superV
                }
                self.targetViewPoint = point
            }
        }
    }
    var targetViewPoint: CGPoint? //指向的目标视图在屏幕上的位置
    
    init(targetView: UIView?,innerSize: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.targetView = targetView
        self.innerViewSize = innerSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        triangleView = TriangleRectView(frame: CGRect(x: 0, y: 0, width: triangleSize.width, height: triangleSize.height))
        triangleView.backgroundColor = UIColor(white: 0, alpha: 0)
        self.view.addSubview(triangleView)
        
        initOtherView()
        
        registerGesture()
        
        updatePopPosition()
    }
    
    private func registerGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !triangleView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    //MARK: 等着子类实例化
    func initOtherView() {}
    func updatePopPosition() {}
    /**
     0: 气泡的中心点
     1: 气泡的点的构成(相对点)
     */
    func calculatePopOverPosition() -> (CGPoint,[CGPoint]) { return (CGPoint(x: 0, y: 0),[])}
}
