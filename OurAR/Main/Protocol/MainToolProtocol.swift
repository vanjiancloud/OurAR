//
//  MainToolProtocol.swift
//  OurAR
//
//  Created by lee on 2023/6/25.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation

protocol MainToolProtocol
{
    func handleMainToolClick(type: MainToolType)
    func handleSecondToolClick(mainType: MainToolType,type: SecondToolType)
    func handleMainToolClose(type: MainToolType)
}


final class VJMTDelegateManager
{
    static let mtDelegate = MulticastDelegate<MainToolProtocol>()
    
    static func add(_ delegate: MainToolProtocol)
    {
        mtDelegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: MainToolProtocol)
    {
        mtDelegate.removeDelegate(delegate)
    }
    
    static func notity(mainType: MainToolType)
    {
        mtDelegate.notifyDelegates()
        {
            $0.handleMainToolClick(type:mainType)
        }
    }
    
    static func notity(mainType: MainToolType,secondType: SecondToolType)
    {
        mtDelegate.notifyDelegates () {
            $0.handleSecondToolClick(mainType: mainType,type: secondType)
        }
    }
    
    static func notity(needClosedMainType: MainToolType)
    {
        mtDelegate.notifyDelegates()
        {
            $0.handleMainToolClose(type: needClosedMainType)
        }
    }
}
