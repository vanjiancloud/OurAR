//
//  ModelLaunchProtocol.swift
//  OurAR
//
//  Created by lee on 2023/7/1.
//  Copyright © 2023 NVIDIA. All rights reserved.
//


import Foundation
import CloudAR

protocol ModelLaunchProtocol
{
    func handleModelClose()
}

protocol ModelLoadFinishProtocol
{
    func handleModelLoadFinish(isSuccess: Bool, reason: String, screenType: car_ScreenMode, project: String)
}


final class MLDelegateManager
{
    static let Delegate = MulticastDelegate<ModelLaunchProtocol>()
    
    static func add(_ delegate: ModelLaunchProtocol)
    {
        Delegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: ModelLaunchProtocol)
    {
        Delegate.removeDelegate(delegate)
    }
    
    static func notity()
    {
        Delegate.notifyDelegates()
        {
            $0.handleModelClose()
        }
    }
    
}
