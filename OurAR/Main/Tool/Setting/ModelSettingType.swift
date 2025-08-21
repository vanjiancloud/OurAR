//
//  ModelSettingType.swift
//  OurAR
//
//  Created by lewen on 2025/8/20.
//

import Foundation
import UIKit

class ModelSettingType : UIView {
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
        
        addSubview(inLabel)
        inLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(ftLabel)
        ftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mmLabel)
        mmLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cmLabel)
        cmLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mLabel)
        mLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            inLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            inLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            inLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            inLabel.heightAnchor.constraint(equalToConstant: 40),
            
            ftLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            ftLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            ftLabel.bottomAnchor.constraint(equalTo: inLabel.topAnchor, constant: 0),
            ftLabel.heightAnchor.constraint(equalToConstant: 40),
            
            mmLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mmLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mmLabel.bottomAnchor.constraint(equalTo: ftLabel.topAnchor, constant: 0),
            mmLabel.heightAnchor.constraint(equalToConstant: 40),
            
            cmLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            cmLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            cmLabel.bottomAnchor.constraint(equalTo: mmLabel.topAnchor, constant: 0),
            cmLabel.heightAnchor.constraint(equalToConstant: 40),
            
            mLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            mLabel.bottomAnchor.constraint(equalTo: cmLabel.topAnchor, constant: 0),
            mLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleInTap))
        inLabel.addGestureRecognizer(tapGesture)
        
        let ftGesture = UITapGestureRecognizer(target: self, action: #selector(handleFtTap))
        ftLabel.addGestureRecognizer(ftGesture)
        
        let mmGesture = UITapGestureRecognizer(target: self, action: #selector(handleMmTap))
        mmLabel.addGestureRecognizer(mmGesture)
        
        let cmGesture = UITapGestureRecognizer(target: self, action: #selector(handleCmTap))
        cmLabel.addGestureRecognizer(cmGesture)
        
        let mGesture = UITapGestureRecognizer(target: self, action: #selector(handleMTap))
        mLabel.addGestureRecognizer(mGesture)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    let inLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "in"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onInViewTapped: (() -> Void)?
    
    @objc private func handleInTap() {
        inLabel.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        cmLabel.textColor = .black
        mmLabel.textColor = .black
        ftLabel.textColor = .black
        mLabel.textColor = .black
        onInViewTapped?()
        
        self.isHidden = true
    }
    
    let ftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "ft"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onFtViewTapped: (() -> Void)?
    
    @objc private func handleFtTap() {
        ftLabel.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        cmLabel.textColor = .black
        mmLabel.textColor = .black
        mLabel.textColor = .black
        inLabel.textColor = .black
        onFtViewTapped?()
        
        self.isHidden = true
    }
    
    let mmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "mm"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onMmViewTapped: (() -> Void)?
    
    @objc private func handleMmTap() {
        mmLabel.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        cmLabel.textColor = .black
        mLabel.textColor = .black
        ftLabel.textColor = .black
        inLabel.textColor = .black
        onMmViewTapped?()
        
        self.isHidden = true
    }
    
    let cmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "cm"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onCmViewTapped: (() -> Void)?
    
    @objc private func handleCmTap() {
        cmLabel.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        mLabel.textColor = .black
        mmLabel.textColor = .black
        ftLabel.textColor = .black
        inLabel.textColor = .black
        onCmViewTapped?()
        
        self.isHidden = true
    }
    
    let mLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        label.text = "m"
        label.isUserInteractionEnabled = true;
        return label
    }()
    var onMViewTapped: (() -> Void)?
    
    @objc private func handleMTap() {
        mLabel.textColor = UIColor(red: 20/255.0, green: 151/255.0, blue: 236/255.0, alpha: 1.0)
        cmLabel.textColor = .black
        mmLabel.textColor = .black
        ftLabel.textColor = .black
        inLabel.textColor = .black
        onMViewTapped?()
        
        self.isHidden = true
    }
}
