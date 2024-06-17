//
//  GJSCellProcotol.swift
//  OurAR
//
//  Created by lee on 2023/7/28.
//

import Foundation

protocol GJSCellPtocotol
{
    func handleCellEvent(_ id: String,params: [String:Any])
}

final class GJSDelegateManager
{
    static let Delegate = MulticastDelegate<GJSCellPtocotol>()
    
    static func add(_ delegate: GJSCellPtocotol)
    {
        Delegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: GJSCellPtocotol)
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
