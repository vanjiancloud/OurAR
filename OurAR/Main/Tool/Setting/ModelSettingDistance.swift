//
//  ModelSettingDistance.swift
//  OurAR
//
//  Created by lewen on 2025/8/20.
//

import Foundation
import UIKit

class ModelSettingDistance : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(middleLabel)
        middleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            bottomLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            bottomLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            bottomLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
//            bottomLabel.heightAnchor.constraint(equalToConstant: 40),
//            
//            middleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            middleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            middleLabel.bottomAnchor.constraint(equalTo: bottomLabel.bottomAnchor, constant: 0),
//            middleLabel.heightAnchor.constraint(equalToConstant: 40),
//            
//            topLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            topLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            topLabel.bottomAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: 0),
//            topLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomTap))
        bottomLabel.addGestureRecognizer(tapGesture)
        
        let middleGesture = UITapGestureRecognizer(target: self, action: #selector(handleMiddleTap))
        middleLabel.addGestureRecognizer(middleGesture)
        
        let topGesture = UITapGestureRecognizer(target: self, action: #selector(handleTopTap))
        topLabel.addGestureRecognizer(topGesture)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "0.01"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onBottomViewTapped: (() -> Void)?
    
    @objc private func handleBottomTap() {
        onBottomViewTapped?()
    }
    
    let middleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "0.1"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onMiddleViewTapped: (() -> Void)?
    
    @objc private func handleMiddleTap() {
        onMiddleViewTapped?()
    }
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "0"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onTopViewTapped: (() -> Void)?
    
    @objc private func handleTopTap() {
        onTopViewTapped?()
    }
}
