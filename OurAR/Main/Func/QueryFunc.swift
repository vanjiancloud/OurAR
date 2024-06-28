//
//  QueryFunc.swift
//  OurAR
//
//  Created by lee on 2023/7/24.
//

import Foundation
import CloudAR
import Alamofire

//MARK: 请求项目列表
public func queryApplicationList(completion: @escaping (Result<Data, Error>) -> Void) {
    
    // 这里执行异步操作，例如网络请求或长时间的计算任务
    // 当任务完成时，调用 completion 闭包并传递结果或错误
    
    let url = car_URL.urlPre + "appli/getApplicationList?userid=\(car_UserInfo.userID)&pageNo=1&pageSize=200"
    AF.request(url,method: .get).response { (response:AFDataResponse) in
        switch response.result {
            case .success(let JSON):
                print("request project list success")
                completion(.success(JSON ?? Data()))
            case .failure(let error):
            print("request project list failed")
                completion(.failure(error))
        }
    }
}

//MARK: 请求使用信息
public func queryCountInfo(completion: @escaping (Result<Data,Error>) -> Void) {
    let url = car_URL.urlPre + "CountManager/getCountDetail?userid=\(car_UserInfo.userID)"
    AF.request(url,method: .get).response { (response:AFDataResponse) in
        switch response.result {
            case .success(let JSON):
                do {
                    completion(.success(JSON ?? Data()))
                }
            case .failure(let error):
            completion(.failure(error))
        }
    }
}

//MARK: 请求服务地址
public func queryAddress(request: inout DataRequest?,completion: @escaping (Result<Data,Error>) -> Void) {
    // TODO: 接口🈚️
    let url = car_URL.urlPre + ""
    request = AF.request(url,method:.get)
    request?.response { (response:AFDataResponse) in
        switch response.result {
        case .success(let JSON):
            do {
                print("query address sucess")
                completion(.success(JSON ?? Data()))
            }
        case .failure(let error):
            print("query address failed")
            completion(.failure(error))
        }
    }
}

//MARK: 获取token，用于请求模型
public func queryTokenForLoadModel(request: inout DataRequest?,auth: String,password: String,projectID: String,completion: @escaping (Result<String,Error>) -> Void)
{
    let url = car_URL.urlPre + "OurBim/getAccessToken?appid=\(projectID)&auth=\(auth)&password=\(password)"
    
    request = AF.request(url,method:.post).response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                if code == 0 {
                    if let token = json["data"] as? String {
                        completion(.success(token))
                    } else {
                        completion(.failure(car_FError.customError(message: "not found data")))
                    }
                } else {
                    completion(.failure(car_FError.customError(message: msg)))
                }
            } else {
                completion(.failure(car_FError.customError(message: "not found code or message")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

//
func queryARModel(request: inout DataRequest?,token: String,projectID: String,completion: @escaping (Result<String,Error>) ->Void) {
    if car_UserInfo.hostID.isEmpty {
        completion(.failure(car_FError.customError(message: "vjuserinfo's custom address is empty")))
        return
    }
    let url = car_URL.urlPre + "OurBim/requestOurBim?appliId=\(projectID)&token=\(token)&appType=ar&senderId=\(car_UserInfo.senderID)&nonce=\(arc4random())&hostId=\(car_UserInfo.hostID)&mode=reboot"
    request = AF.request(url,method:.post)
    request?.response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                if code == 0 {
                    if let data = json["data"] as? String {
                        completion(.success(data))
                    }
                } else {
                    completion(.failure(car_FError.customError(message: msg)))
                }
            } else {
                completion(.failure(car_FError.customError(message: "not found code or message")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

fileprivate func requestARModel(request: inout DataRequest?,token: String,taskId: String,projectID: String,completion: @escaping (Result<String,Error>) ->Void) {
    if car_UserInfo.hostID.isEmpty {
        completion(.failure(car_FError.customError(message: "userinfo's hostID is empty")))
        return
    }
    //accessMode 1:正常模式 2：协同模式 3：互动模式
    let url = car_URL.urlPre + "OurBim/startXr?appliId=\(projectID)&token=\(token)&plateType=3&senderId=\(car_UserInfo.senderID)&nonce=\(arc4random())&hostId=\(car_UserInfo.hostID)&mode=reboot&taskId=\(taskId)&accessMode=1"
    request = AF.request(url,method:.post)
    request?.response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String
            {
                if code == 0 {
                    completion(.success(msg))
                } else {
                    completion(.failure(car_FError.customError(message: msg)))
                }
            } else {
                completion(.failure(car_FError.customError(message: "not found code or message")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

//MARK: 请求加载AR模型
func requestARModelLoad(request: inout DataRequest?,token:String,taskId:String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    //请求模型
    print("请求加载AR模型 ------- \(projectID)")
    requestARModel(request: &request,token: token, taskId: taskId,projectID: projectID) { result in
        switch result {
        case .success(_):
            completion(true,"")
        case .failure(let error):
            print(error)
            if let carError = error as? car_FError {
                switch carError {
                case .customError(let message):
                    completion(false,message)
                    break
                }
            } else {
                completion(false,String(describing: error))
            }
            
        }
    }
}

//MARK: 以OurBim的方式请求加载AR模型
public func queryARModelLoad(request: inout DataRequest?,token:String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    //请求模型
    queryARModel(request: &request,token: token, projectID: projectID) { result in
        switch result {
        case .success(let string):
            car_UserInfo.taskID = string
            car_UserInfo.currProID = projectID
            completion(true,"")
        case .failure(let error):
            print(error)
            if let carError = error as? car_FError {
                switch carError {
                case .customError(let message):
                    completion(false,message)
                    break
                }
            } else {
                completion(false,String(describing: error))
            }
            
        }
    }
}

//MARK: 关闭云AR模型
public func queryARModelClose(completion: @escaping (Bool) -> Void) {
    if car_UserInfo.hostID.isEmpty || car_UserInfo.senderID.isEmpty || car_UserInfo.taskID.isEmpty {
        print("query model close failed,address or senderid or taskid is empty")
        completion(false)
        return
    }
    
    let url = car_URL.xrUrlPre + "v1/ShutDownTask?SenderId=\(car_UserInfo.senderID)&HostId=\(car_UserInfo.hostID)&nonce=\(arc4random())&taskid=\(car_UserInfo.taskID)"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        switch response.result {
        case .success(let JSON):
            do {
                if let jsonObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments),
                   let json = jsonObject as? [String:Any],
                   let success = json["success"] as? Bool
                {
                    completion(success)
                    if success {
                        car_UserInfo.currProID = ""
                        car_UserInfo.taskID = ""
                    }
                } else {
                    print("query model close failed,not found success")
                    completion(false)
                }
            }
        case .failure(let Error):
            print("query model close failed, \(Error)")
            completion(false)
        }
    }
}

//MARK: 查询属性信息
public func queryPropertyInfo(projectID: String,actorID: String,completion: @escaping (Result<Data,Error>) -> Void) {
    //  api.OurBim.com:11022/vjapi/comControl/getComInfoByActorId?appId=BIM2022031210421053&actorId=436967
    let url = car_URL.urlPre + "comControl/getComInfoByActorId?appId=\(projectID)&actorId=\(actorID)"
    AF.request(url,method: .get).response { (response: AFDataResponse) in
        switch response.result {
        case .success(let JSON):
            do {
                completion(.success(JSON ?? Data()))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

/**
  Bool: 成功或失败
  String：原因
 */
public func queryThreeDModelLoad(request: inout DataRequest?,token:String,projectID: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/requestOurBim?appliId=\(projectID)&token=\(token)"
    request = AF.request(url,method:.post)
    request?.response { (response: AFDataResponse) in
        switch response.result {
        case .success(let JSON):
            do {
                if let jsonObject = try? JSONSerialization.jsonObject(with: JSON ?? Data(), options: .allowFragments),
                   let json = jsonObject as? [String:Any],
                   let code = json["code"] as? Int,
                   let message = json["message"] as? String,
                   let data = json["data"] as? [String:Any]
                {
                    if code == 0 {
                        if let taskID = data["taskId"] as? String,
                           let url = data["url"] as? String
                        {
                            car_UserInfo.taskID = taskID
                            car_UserInfo.currProID = projectID
                            car_UserInfo.threeDURL = url
                            completion(true,"success")
                        } else {
                            completion(false,"not found url or taskid")
                        }
                    } else {
                        completion(false,message)
                    }
                } else {
                    completion(false,"response data error")
                }
            }
        case .failure(_):
            completion(false,"response fail")
            break
        }
    }
}

//MARK: 手机号是否不存在
func phoneNotExist(phone: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/repeatMobile?mobile=\(phone)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}
//MARK: 手机号是否存在
func phoneIsExist(phone: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/MobileIsHave?mobile=\(phone)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}
//MARK: 发送验证码
func sendVerificationCode(phone: String,type: VerificationType,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/sendMsgCode?mobile=\(phone)&msgType=\(type.rawValue)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}
//MARK: 注册新用户
func registerUser(phone: String,psd: String,verificationCode: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/addUser?mobile=\(phone)&password=\(psd)&code=\(verificationCode)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}
//MARK: 重置密码
func resetPassword(phone: String,psd: String,verificationCode: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "UserCenter/updatePassword?mobile=\(phone)&password=\(psd)&code=\(verificationCode)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}
