//
//  MulticastDelegate.swift
//  OurAR
//
//  Created by lee on 2023/6/3.
//  Copyright © 2023 NVIDIA. All rights reserved.
//

import Foundation

final public class MulticastDelegate<ProtocolType> {

    // MARK: - Helper Types

    private final class DelegateWrapper {
        weak var delegate: AnyObject?
        init(delegate: AnyObject) { self.delegate = delegate }
    }

    // MARK: - Properties

    private var delegateWrappers: [DelegateWrapper]
    private var delegates: [ProtocolType] {
        delegateWrappers = delegateWrappers.filter { $0.delegate != nil }
        return delegateWrappers.map { $0.delegate } as! [ProtocolType]
    }

    // MARK: - Initializers

    public init(delegates: [ProtocolType] = []) {
        delegateWrappers = delegates
            .map { DelegateWrapper(delegate: $0 as AnyObject)}
    }

    // MARK: - Delegate Management

    public func addDelegate(_ delegate: ProtocolType) {
        let wrapper = DelegateWrapper(delegate: delegate as AnyObject)
        delegateWrappers.append(wrapper)
    }

    public func removeDelegate(_ delegate: ProtocolType) {
        guard let index = delegateWrappers
            .firstIndex(where: { $0.delegate === (delegate as AnyObject)}) else {
                return
        }
        delegateWrappers.remove(at: index)
    }

    public func notifyDelegates(_ closure: (ProtocolType) -> Void) {
        delegates.forEach { closure($0) }
    }
}
