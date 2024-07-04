//
//  SegmentedControlImageProcotol.swift
//  OurAR
//
//  Created by lee on 2023/8/29.
//

import Foundation
import UIKit

//===========================================
// MARK: SegmentedControlFactory
//===========================================
protocol SegmentedControlImageFactory {
    var edgeOffset: CGFloat { get }
    func background(color: UIColor) -> UIImage?
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage?
}

extension SegmentedControlImageFactory {
    var edgeOffset: CGFloat { return 0 }
    func background(color: UIColor) -> UIImage? { return nil }
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage? { return nil }
}

struct DefaultSegmentedControlImageFactory: SegmentedControlImageFactory { }

//===========================================
// MARK: Underline
//===========================================
struct UnderlinedSegmentedControlImageFactory: SegmentedControlImageFactory {
    var size = CGSize(width: 2, height: 29)
    var lineWidth: CGFloat = 2
    
    func background(color: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            color.setFill()
            UIRectFill(CGRect(x: 0, y: size.height-lineWidth, width: size.width, height: lineWidth))
        }
    }
    
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            UIColor.clear.setFill()
        }
    }
}

//===========================================
// MARK: Pill
//===========================================
struct PillSegmentedControlImageFactory: SegmentedControlImageFactory {
    var size = CGSize(width: 32, height: 32)
    let edgeOffset: CGFloat = 8
    
    func background(color: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            color.setFill()
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: size.height/2)
                .fill()
        }
    }
    
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            let radius = size.height/2
            
            leftColor.setFill()
            UIBezierPath(arcCenter: CGPoint(x: 0, y: radius), radius: radius, startAngle: CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: false)
                .fill()
            
            rightColor.setFill()
            UIBezierPath(arcCenter: CGPoint(x: size.width, y: radius), radius: radius, startAngle: CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: true)
                .fill()
        }
    }
}

//===========================================
// MARK: Tab
//===========================================
struct TabSegmentedControlImageFactory: SegmentedControlImageFactory {
    let edgeOffset: CGFloat = 4
    func background(color: UIColor) -> UIImage? {
        let size = CGSize(width: 32, height: 29)
        
        return UIImage.render(size: size) {
            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: size.width*0.75, y: 0))
            path.addLine(to: CGPoint(x: size.width*0.25, y: 0))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            
            path.lineWidth = 1.0
            path.stroke()
            
            path.close()
            color.setFill()
            path.fill()
        }
    }
    
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage? {
        let size = CGSize(width: 32*0.25, height: 29)
        return UIImage.render(size: size) {
            let leftPath = UIBezierPath()
            leftPath.move(to: .zero)
            leftPath.addLine(to: CGPoint(x: size.width, y: size.height))
            leftPath.addLine(to: CGPoint(x: 0, y: size.height))
            leftPath.close()
            leftColor.setFill()
            leftPath.fill()
            
            let rightPath = UIBezierPath()
            rightPath.move(to: .zero)
            rightPath.addLine(to: CGPoint(x: size.width, y: 0))
            rightPath.addLine(to: CGPoint(x: size.width, y: size.height))
            rightPath.close()
            rightColor.setFill()
            rightPath.fill()
            
            UIColor.white.setFill()
            let path = UIBezierPath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.lineWidth = 1.0
            path.stroke()
        }
    }
}

//===========================================
// MARK: Segmented Control Builder
//===========================================
struct SegmentedControlBuilder {
    var boldStates: [UIControl.State] = [.selected, .highlighted]
    var boldFont = UIFont.boldSystemFont(ofSize: 14)
    var tintColor = UIColor.white
    var apportionsSegmentWidthsByContent = true
    
    private let imageFactory: SegmentedControlImageFactory
    
    init(imageFactory: SegmentedControlImageFactory = DefaultSegmentedControlImageFactory()) {
        self.imageFactory = imageFactory
    }
    
    func makeSegmentedControl(items: [UIImage]) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        build(segmentedControl: segmentedControl)
        if let height = items.first?.size.height {
            segmentedControl.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return segmentedControl
    }

    func makeSegmentedControl(items: [String]) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        build(segmentedControl: segmentedControl)
        return segmentedControl
    }
    
    func build(segmentedControl: UISegmentedControl) {
        segmentedControl.apportionsSegmentWidthsByContent = apportionsSegmentWidthsByContent
        segmentedControl.tintColor = tintColor
        segmentedControl.selectedSegmentIndex = 0

        boldStates
            .forEach { (state: UIControl.State) in
                let attributes = [NSAttributedString.Key.font: boldFont]
                segmentedControl.setTitleTextAttributes(attributes, for: state)
        }
        
        let controlStates: [UIControl.State] = [
            .normal,
            .selected,
            .highlighted,
            [.highlighted, .selected]
        ]
        
        controlStates.forEach { state in
            let image = background(for: state)
            segmentedControl.setBackgroundImage(image, for: state, barMetrics: .default)
            
            controlStates.forEach { state2 in
                let image = divider(leftState: state, rightState: state2)
                segmentedControl.setDividerImage(image, forLeftSegmentState: state, rightSegmentState: state2, barMetrics: .default)
            }
        }
        
        [.left, .right]
            .forEach { (type: UISegmentedControl.Segment) in
                let offset = positionAdjustment(forSegmentType: type)
                segmentedControl.setContentPositionAdjustment(offset, forSegmentType: type, barMetrics: .default)
        }
        
        segmentedControl.addTarget(SegmentedControlAnimationRemover.shared, action: #selector(SegmentedControlAnimationRemover.removeAnimation(_:)), for: .valueChanged)
    }
    
    private func color(for state: UIControl.State) -> UIColor {
        switch state {
        case .selected, [.selected, .highlighted]:
            return .white
        case .highlighted:
            return UIColor.white.withAlphaComponent(0.5)
        default:
            return .clear
        }
    }

    private func background(for state: UIControl.State) -> UIImage? {
        return imageFactory.background(color: color(for: state))
    }

    private func divider(leftState: UIControl.State, rightState: UIControl.State) -> UIImage? {
        return imageFactory.divider(leftColor: color(for: leftState), rightColor: color(for: rightState))
    }
    
    private func positionAdjustment(forSegmentType type: UISegmentedControl.Segment) -> UIOffset {
        switch type {
        case .left:
            return UIOffset(horizontal: imageFactory.edgeOffset, vertical: 0)
        case .right:
            return UIOffset(horizontal: -imageFactory.edgeOffset, vertical: 0)
        default:
            return UIOffset(horizontal: 0, vertical: 0)
        }
    }
}

class SegmentedControlAnimationRemover {
    static var shared = SegmentedControlAnimationRemover()
    @objc func removeAnimation(_ control: UISegmentedControl) {
        control.layer.sublayers?.forEach { $0.removeAllAnimations() }
    }
}

//===========================================
// MARK: StackedViewsProvider
//===========================================
protocol StackedViewsProvider {
    var views: [UIView] { get }
}

class SegmentedControlStackedViewsProvider: StackedViewsProvider {
    let items = ["Apple", "Banana", "Carrot"]
    
    lazy var views: [UIView] = {
        return [
            createView(imageFactory: DefaultSegmentedControlImageFactory(), items: items),
            createView(imageFactory: DefaultSegmentedControlImageFactory(), items: items.map { UIImage(named: $0)! }),
            createView(imageFactory: UnderlinedSegmentedControlImageFactory(), items: items),
            createView(imageFactory: PillSegmentedControlImageFactory(), items: items),
            createView(imageFactory: TabSegmentedControlImageFactory(), items: items)
        ]
    }()
    
    private func createView(imageFactory: SegmentedControlImageFactory, items: [String]) -> UIView {
        let builder = SegmentedControlBuilder(imageFactory: imageFactory)
        return builder.makeSegmentedControl(items: items)
    }
    private func createView(imageFactory: SegmentedControlImageFactory, items: [UIImage]) -> UIView {
        let builder = SegmentedControlBuilder(imageFactory: imageFactory)
        return builder.makeSegmentedControl(items: items)
    }
}

//===========================================
// MARK: StackViewController
//===========================================
class StackViewController : UIViewController {
    let stackedViewsProvider: StackedViewsProvider

    init(stackedViewsProvider: StackedViewsProvider) {
        self.stackedViewsProvider = stackedViewsProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .darkGray
        self.view = view
        
        let stackView = UIStackView(arrangedSubviews: stackedViewsProvider.views)
        view.addSubview(stackView)
        
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 32
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
}
