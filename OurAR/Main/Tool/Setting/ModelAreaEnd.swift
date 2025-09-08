//
//  ModelAreaEnd.swift
//  OurAR
//
//  Created by lewen on 2025/9/8.
//

import Foundation
import UIKit

class ModelAreaEnd : UIView, UIGestureRecognizerDelegate {
    let confirmButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("✔️", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    var onConfirmTapped: (() -> Void)?
    
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
    
        let btnTap = UITapGestureRecognizer(target: self, action: #selector(myButtonTap(_:)))
        btnTap.cancelsTouchesInView = true
        btnTap.delegate = self
        confirmButton.addGestureRecognizer(btnTap)
        
        addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            confirmButton.topAnchor.constraint(equalTo: self.topAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 40),
            confirmButton.heightAnchor.constraint(equalToConstant: 40),

        ])
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
   
        let tapXGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapXGesture.cancelsTouchesInView = true
        addGestureRecognizer(tapXGesture)
    }
    
    @objc private func handleBackgroundTap() {
        
    }
    
    @objc func myButtonTap(_ sender: UITapGestureRecognizer) {
        onConfirmTapped?()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
