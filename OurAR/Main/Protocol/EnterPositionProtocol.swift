//
//  EnterPositionProtocol.swift
//  OurAR
//
//  Created by lee on 2023/8/18.
//

import Foundation

protocol EnterPositionPtocotol
{
    func handleEnterPosition()
}

final class EPDelegateManager
{
    static let Delegate = MulticastDelegate<EnterPositionPtocotol>()
    
    static func add(_ delegate: EnterPositionPtocotol)
    {
        Delegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: EnterPositionPtocotol)
    {
        Delegate.removeDelegate(delegate)
    }
    
    static func notity()
    {
        Delegate.notifyDelegates()
        {
            $0.handleEnterPosition()
        }
    }
    
}
