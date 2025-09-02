//
//  ModelLoad.swift
//  OurAR
//
//  Created by lee on 2023/6/2.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation
import UIKit
import CloudAR

//MARK: VJ场景加载的页面
class ModelLoadView: UIView {
    
    var loadImg: UIImageView!
    var LogImg: UIImageView!
    var loadLabel: UILabel!
    var stepLabel: UILabel!
    var backBtn: BackBtnView!
    @objc var progressLabel: UILabel!
    @objc var progressTipsLabel: UILabel!
    @objc var progressBgView: UIView!
    var progressBgWidthConstraint: NSLayoutConstraint!
    var progressLabelLeadingConstraint: NSLayoutConstraint!
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .clear
        progressView.trackTintColor = .clear
        progressView.progress = 0
        progressView.alpha = 0.0
        progressView.layer.cornerRadius = 12.5
        progressView.clipsToBounds = true
        return progressView
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .black
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func initSubView() {
        // 1. 先初始化所有视图
        loadImg = UIImageView()
        loadImg.image = UIImage(named: "loading")
        LogImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        LogImg.image = UIImage(named: "img_loadbg_logo")
        
        loadLabel = UILabel()
        loadLabel.font = UIFont.systemFont(ofSize: 18)
        loadLabel.text = "环境加载中"
        loadLabel.textColor = .white
        loadLabel.textAlignment = .center
        
        stepLabel = UILabel()
        stepLabel.font = UIFont.systemFont(ofSize: 18)
        stepLabel.text = ""
        stepLabel.textColor = .white
        stepLabel.textAlignment = .center
        
        backBtn = BackBtnView(x: 0, y: 20, width: 40, height: 40)
        
        progressBgView = UIView()
        progressBgView.backgroundColor = .clear
        progressBgView.layer.cornerRadius = 12.5
        progressBgView.clipsToBounds = true
        progressBgView.isHidden = false
        
        progressLabel = UILabel()
        progressLabel.textColor = .black
        progressLabel.font = UIFont.systemFont(ofSize: 12)
        progressLabel.isHidden = false
        progressLabel.text = "0%"
        progressLabel.isHidden = true;

        progressTipsLabel = UILabel()
        progressTipsLabel.font = UIFont.systemFont(ofSize: 12)
        progressTipsLabel.text = "BIM模型加载中..."
        progressTipsLabel.textColor = .white
        progressTipsLabel.textAlignment = .center
        progressTipsLabel.backgroundColor = .black
        progressTipsLabel.isHidden = true
        
        // 2. 添加所有子视图
        addSubview(loadImg)
        addSubview(LogImg)
        addSubview(loadLabel)
        addSubview(stepLabel)
        addSubview(backBtn)
        addSubview(progressBgView)
        addSubview(progressLabel)
        addSubview(progressTipsLabel)
        addSubview(progressView)
        
        // 3. 设置约束
        setupConstraints()
        
        self.loadImage()
        self.loadLogoImage()
    }
    
    private func setupConstraints() {
        LogImg.translatesAutoresizingMaskIntoConstraints = false
        loadImg.translatesAutoresizingMaskIntoConstraints = false
        loadLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBgView.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressTipsLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // 通用约束
        NSLayoutConstraint.activate([
            loadImg.topAnchor.constraint(equalTo: topAnchor),
            loadImg.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadImg.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadImg.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            LogImg.widthAnchor.constraint(equalToConstant: 80),
            LogImg.heightAnchor.constraint(equalToConstant:80),
            LogImg.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant:-30),
            LogImg.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            loadLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadLabel.topAnchor.constraint(equalTo: LogImg.bottomAnchor, constant: 10),
            loadLabel.widthAnchor.constraint(equalToConstant: 200),
            loadLabel.heightAnchor.constraint(equalToConstant: 30),
            
            stepLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            stepLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            stepLabel.widthAnchor.constraint(equalToConstant: 300),
            stepLabel.heightAnchor.constraint(equalToConstant: 30),
            
            backBtn.leadingAnchor.constraint(equalTo: leadingAnchor),
            backBtn.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            backBtn.widthAnchor.constraint(equalToConstant: 60),
            backBtn.heightAnchor.constraint(equalToConstant: 40),
            
            progressTipsLabel.widthAnchor.constraint(equalToConstant: 300),
            progressTipsLabel.heightAnchor.constraint(equalToConstant: 25),
            progressTipsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressTipsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            
            progressView.heightAnchor.constraint(equalToConstant: 25),
            progressView.widthAnchor.constraint(equalToConstant: 300),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.bottomAnchor.constraint(equalTo: progressTipsLabel.topAnchor, constant: -6),
            
            progressBgView.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            progressBgView.bottomAnchor.constraint(equalTo: progressTipsLabel.topAnchor, constant: -6),
            progressBgView.heightAnchor.constraint(equalToConstant: 25),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressBgView.centerYAnchor)
        ])
        
        progressBgWidthConstraint = progressBgView.widthAnchor.constraint(equalToConstant: 22)
        progressBgWidthConstraint.isActive = true
        
        progressLabelLeadingConstraint = progressLabel.leadingAnchor.constraint(equalTo: progressBgView.leadingAnchor)
        progressLabelLeadingConstraint.isActive = true
    }

    private func setupViews() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initSubView()
        
//        addSubview(activityIndicatorView)
//        NSLayoutConstraint.activate([
//            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            activityIndicatorView.bottomAnchor.constraint(equalTo: loadLabel.topAnchor, constant: -10)
//        ])
//        activityIndicatorView.startAnimating()
    }

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }
    
    private func loadImage() {
        queryLoadImageInfo(type: "startUpBkgImg") { result in
            switch result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON, options: .allowFragments)
                    if let json = JSONObject as? [String:Any] {
                        if let respCode = json["code"] as? Int,
                            let data = json["data"] as? [String:Any]
                        {
                            if respCode == 0
                            {
                                if let info = data["data"] as? String,
                                   let name = data["name"] as? String,
                                   let uuid = data["uuid"] as? String
                                {
                                }
                            }
                        }
                    }
                }
                
            case .failure(let Error):
                print(Error)
            }
        }
    }
    
    private func loadLogoImage() {
        queryLoadImageInfo(type: "startUpLogo") { result in
            switch result {
            case .success(let JSON):
                do {
                    let JSONObject = try? JSONSerialization.jsonObject(with: JSON, options: .allowFragments)
                    if let json = JSONObject as? [String:Any] {
                        if let respCode = json["code"] as? Int,
                            let data = json["data"] as? [String:Any]
                        {
                            if respCode == 0
                            {
                                if let info = data["data"] as? String,
                                   let name = data["name"] as? String,
                                   let uuid = data["uuid"] as? String
                                {
                                }
                            }
                        }
                    }
                }
                
            case .failure(let Error):
                print(Error)
            }
        }
    }
}
