//
//  TagCellProcotol.swift
//  OurAR
//
//  Created by lee on 2023/7/26.
//

import Foundation

protocol TagCellPtocotol
{
    func handleCellEvent(_ id: String,params: [String:Any])
}

final class TCDelegateManager
{
    static let Delegate = MulticastDelegate<TagCellPtocotol>()
    
    static func add(_ delegate: TagCellPtocotol)
    {
        Delegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: TagCellPtocotol)
    {
        Delegate.removeDelegate(delegate)
    }
    
    static func notity(id: String,params: [String:Any])
    {
        Delegate.notifyDelegates()
        {
            $0.handleCellEvent(id, params: params)
        }
    }
    
}
