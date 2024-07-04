//
//  WebSocketClient.swift
//  OurAR
//
//  Created by lee on 2023/7/19.
//

import Foundation
import Starscream
import CloudAR

class WebSocketClient : WebSocketDelegate,ModelLaunchProtocol
{
    public static let shared = WebSocketClient()
    
    private var socket: WebSocket?
    private var isConnected = false
    var reConnectTime = 0 // 设置重连次数
    let reConnectMaxTime = 100 // 设置最大重连次数
    private var pingTimer: Timer?
    private let pingInterval: TimeInterval = 30
 
    private func startPingTimer() {
        if  pingTimer == nil {
            pingTimer = Timer.scheduledTimer(timeInterval: pingInterval, target: self, selector: #selector(pingWebSocket), userInfo: nil, repeats: true)
        }
    }
 
    @objc private func pingWebSocket() {
        print("send --- ping")
        socket?.write(ping: Data()) // 发送Ping消息
    }
    
    //保持单例
    private init() {
        MLDelegateManager.add(self)
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            startPingTimer()
            print("ws connect success, headers:\(headers)")
        case let .disconnected(reason, code):
            isConnected = false
            print("disconnect, reason:\(reason),code:\(code)")
        case let .text(string):
            handleReceiverMessage(string: string)
        case let .binary(data):
            print("ws receive binary")
            handleReceiverMessage(data: data)
        case .pong:
            print("pong")
        case .ping:
            print("ping")
        case .viabilityChanged:
            print("viabilityChanged")
            break
        case .reconnectSuggested:
            print("reconnectSuggested")
            break
        case .cancelled:
            isConnected = false
            WebSocketClient.shared.connect()
            print("ws connect cancel")
            break
        case let .error(error):
            isConnected = false
            print("ws connect error:\(String(describing: error))")
            break
        case .peerClosed:
            print("peerClosed")
            break
        }
    }
    
    private func validOfURL() -> (Bool,String) {
        return (!car_UserInfo.taskID.isEmpty,"\(car_URL.javaWS)/vjapi/websocket/\(car_UserInfo.taskID)")
    }
    
    //MARK: 普通连接
    func connect() {
        let (valid,url) = validOfURL()
        if !valid {
            print("\(#function),\(url) is invalid")
            return
        }
        print("-------- ws ----------")
        print("\(car_URL.javaWS)")
        print("\(url)")
        if socket == nil {
            var request = URLRequest(url: URL(string: url)!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        } else if !isConnected {
            socket?.connect()
        }
    }
    
    //MARK: 异步消息发送,能够保证是否发送成功
    func sendMessage(_ message: String,completion: @escaping (Bool) -> Void) {
        if !isConnected {
            let (valid,url) = validOfURL()
            if !valid {
                return
            }
            
            if socket == nil {
                var request = URLRequest(url: URL(string: url)!)
                request.timeoutInterval = 5
                socket = WebSocket(request: request)
                socket?.delegate = self
            }
            
            socket?.onEvent = { event in
                switch event {
                case .connected:
                    self.socket?.write(string: message)
                    completion(true)
                default:
                    completion(false)
                }
            }
        } else
        {
            socket?.write(string: message)
            completion(true)
        }
    }
    
    //MARK: 处理接收到的消息
    private func handleReceiverMessage(data: Data) {
        guard var json = car_dataToJson(from: data)
        else {
            print("\(#function),data convert to json failed")
            return
        }
        dispatchReceiverMsg(json: &json)
        
    }
    private func handleReceiverMessage(string: String) {
        if let data = string.data(using: .utf8) {
            if var json = car_dataToJson(from: data) {
                dispatchReceiverMsg(json: &json)
            } else {
                print("\(#function),convert data to json failed: \(string)")
            }
        } else {
            print("\(#function),convert string to data failed")
        }
    }
   
    //MARK: 自我规定一下
    // 这是广播到其他地方，本人以为该函数会频繁调用并产生大量数据开辟大量空间，由此采用inout
    // 采用inout，但不应该去修改里面的值，所以约定好，不能修改
    private func dispatchReceiverMsg(json: inout [String:Any]) {
       
        if let _ = json["id"] as? String {
            // 通过多播进行事件分发
            SEDelegateManager.notity(json: &json)
        } else {
            print("\(#function),not found is in json")
        }
    }
    
    func close() {
        pingTimer?.invalidate()
        pingTimer = nil
        socket?.forceDisconnect()
        socket = nil
    }
    
    func handleModelClose() {
        print("handleModelClose - close")
        WebSocketClient.shared.close()
    }
}
