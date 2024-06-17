//
//  WSDelegate.swift
//  OurAR
//
//  Created by lee on 2023/6/21.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation

enum WSReceiverType : UInt8
{
    case Data       = 0
    case String     = 1
}

protocol SocketEventProtocol
{
    func handleReceiverMsg(json: inout [String:Any])
}

final class SEDelegateManager
{
    static let ceDelegate = MulticastDelegate<SocketEventProtocol>()
    
    static func add(_ delegate: SocketEventProtocol)
    {
        ceDelegate.addDelegate(delegate)
    }
    
    static func remove(_ delegate: SocketEventProtocol)
    {
        ceDelegate.removeDelegate(delegate)
    }
    
    static func notity(json: inout [String:Any])
    {
        ceDelegate.notifyDelegates()
        {
            $0.handleReceiverMsg(json: &json)
        }
    }
}
