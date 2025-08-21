//
//  ModelSettingAlert.swift
//  OurAR
//
//  Created by lewen on 2025/8/13.
//

import Foundation
import UIKit

class ModelSettingAlert : UIView {
    let bottomSubview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    var onBottomViewTapped: (() -> Void)?
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.text = "0.01"
        return label
    }()
    
    let bottomImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "model_setting_choose") {
            imageView.image = image
        }
        return imageView
    }()
    
    let topSubview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    var onTopViewTapped: (() -> Void)?
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.text = "m"
        return label
    }()
    
    let topImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "model_setting_choose") {
            imageView.image = image
        }
        return imageView
    }()
    
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
        
        addSubview(bottomSubview)
        bottomSubview.translatesAutoresizingMaskIntoConstraints = false
        
        bottomSubview.addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(topSubview)
        topSubview.translatesAutoresizingMaskIntoConstraints = false
        
        topSubview.addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomSubview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            bottomSubview.heightAnchor.constraint(equalToConstant: 40),
            bottomSubview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            bottomSubview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            bottomLabel.leadingAnchor.constraint(equalTo: bottomSubview.leadingAnchor, constant: 20),
            bottomLabel.centerYAnchor.constraint(equalTo: bottomSubview.centerYAnchor),
            
            topSubview.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            topSubview.heightAnchor.constraint(equalToConstant: 40),
            topSubview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            topSubview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            topLabel.leadingAnchor.constraint(equalTo: topSubview.leadingAnchor, constant: 20),
            topLabel.centerYAnchor.constraint(equalTo: topSubview.centerYAnchor),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBottomViewTap))
        bottomSubview.addGestureRecognizer(tapGesture)
        bottomSubview.isUserInteractionEnabled = true
        
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTopViewTap))
        topSubview.addGestureRecognizer(topTapGesture)
        topSubview.isUserInteractionEnabled = true
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
   
        let tapXGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapXGesture)
    }
    
    @objc private func handleBackgroundTap() {
        
    }
    
    @objc private func handleBottomViewTap() {
        onBottomViewTapped?()
    }
    
    @objc private func handleTopViewTap() {
        onTopViewTapped?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
