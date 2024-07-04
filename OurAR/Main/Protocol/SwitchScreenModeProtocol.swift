//
//  SwitchScreenModeDelegate.swift
//  OurAR
//
//  Created by lee on 2023/6/3.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation
import CloudAR

protocol SwitchScreenModeProtocol
{
    func handleSwitchScreenMode(toScreenMode: car_ScreenMode)
}

final class SSMDelegateManager
{
    static let switchScreenModeDelegate = MulticastDelegate<SwitchScreenModeProtocol>()
    
    static func add(_ delegate: SwitchScreenModeProtocol)
    {
        switchScreenModeDelegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: SwitchScreenModeProtocol)
    {
        switchScreenModeDelegate.removeDelegate(delegate)
    }
    
    static func notity(toScreenMode: car_ScreenMode)
    {
        car_EngineStatus.screenMode = toScreenMode
        switchScreenModeDelegate.notifyDelegates()
        {
            $0.handleSwitchScreenMode(toScreenMode: toScreenMode)
        }
    }
    
}
