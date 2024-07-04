//
//  ViewFunc.swift
//  OurAR
//
//  Created by lee on 2023/7/5.
//

import Foundation
import UIKit
import CloudAR

//MARK: 展示一个tip
public func showTip(tip: String,parentView: UIView,center: CGPoint = CGPoint(x: 0, y: 0),_ bgColor: UIColor,_ textColor: UIColor,completion: @escaping () -> Void)
{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: min(parentView.bounds.width*0.35,400), height: 20))
    label.center = CGPoint(x: parentView.bounds.width / 2,y: parentView.bounds.height * 0.2)
    label.contentMode = .center
    label.textAlignment = .center
    label.text = tip
    label.textColor = textColor
    label.backgroundColor = bgColor
    label.font = .systemFont(ofSize: 16)
    parentView.addSubview(label)
    
    UIView.animate(withDuration: 1.0, animations: {
        label.alpha = 0.5
    }) { (_) in
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1
        } completion: { (_) in
            label.removeFromSuperview()
            completion()
        }
    }
}

//MARK: 进入项目的统一入口: 先请求模型，模型请求完成进入BIMScreen
func enterBIMScreen(currViewController: UIViewController)
{
    let bimScreenController = BIMScreenController()
    bimScreenController.modalPresentationStyle = .fullScreen
    currViewController.present(bimScreenController, animated: false,completion: nil)
}
//MARK: 带项目id的场景加载方法
func enterBIMScreen(currViewController: UIViewController,needLoadProject: String,screenType: car_ScreenMode) -> (Bool,String)
{
    //ar模式不能频繁启动，需要有一段缓冲期 目前设置的8秒
    let canEnter: Bool =
        screenType == .AR ?
            car_EngineStatus.lastExitARTime > 0 ? ((Date().timeStamp - car_EngineStatus.lastExitARTime) > 10) : true
            :
            true
    if screenType == .AR {
        print("time internval: \(Date().timeStamp - car_EngineStatus.lastExitARTime),lsatTime: \(car_EngineStatus.lastExitARTime)")
        print("\((Date().timeStamp - car_EngineStatus.lastExitARTime) > 10)")
    }
    let reason = canEnter  ? "" : "稍后再试"
    if canEnter {
        let bimScreenController = BIMScreenController()
        bimScreenController.modalPresentationStyle = .fullScreen
        currViewController.present(bimScreenController, animated: false,completion: nil)
        bimScreenController.LoadModel(projectID: needLoadProject, screenType: screenType)
    }
    
    return (canEnter,reason)
}

//MARK: 制作一个mask
func makeMask(_ cornerRadius: CGFloat,_ viewBounds: CGRect,_ roundingCorn: UIRectCorner) -> CAShapeLayer
{
    // 创建圆角路径
    let maskPath = UIBezierPath(
        roundedRect: viewBounds,
        byRoundingCorners: roundingCorn,
        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
    )
    // 创建一个 shape layer
    let maskLayer = CAShapeLayer()
    maskLayer.path = maskPath.cgPath
    
    return maskLayer
}

//MARK: 获得subview的顶视图的controller
func getControllerOfSubview(_ subview: UIView!) -> UIViewController!
{
    var viewController: UIViewController?
    if let view  = subview
    {
        var superview = view.superview
        while superview != nil
        {
            if let nextResponder = superview?.next, let vc = nextResponder as? UIViewController
            {
                viewController = vc
                break
            }
            superview = superview?.superview
        }
    }
    
    return viewController
}

func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            print("Error loading image: \(error)")
            completion(nil)
            return
        }
        
        if let data = data, let image = UIImage(data: data) {
            completion(image)
        } else {
            completion(nil)
        }
    }.resume()
}

func createUnderlinedSegmentedView(items: [String]) -> UISegmentedControl {
    let builder = SegmentedControlBuilder(imageFactory: UnderlinedSegmentedControlImageFactory())
    return builder.makeSegmentedControl(items: items)
}
