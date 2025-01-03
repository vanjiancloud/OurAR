//
//  ModelFunc.swift
//  OurAR
//
//  Created by chao chao on 2024/5/9.
//

import Foundation
import CloudAR
import Alamofire

//MARK: 获取token，用于请求模型
public func requestToken(request: inout DataRequest?,projectID: String,completion: @escaping (Result<String,Error>) -> Void)
{
    let url = car_URL.urlPre + "OurBim/getEnterToken?appid=\(projectID)"
    
    request = AF.request(url,method:.get).response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String,
               let data = json["data"] as? [String:Any]
            {
                if code == 0 {
                    let token = data["token"] as? String
                    car_UserInfo.tokenData = token!
                    completion(.success(token!))
                }else {
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

//MARK: 获取公共ip和hostID
public func requestIPwithHostID(request: inout DataRequest?,token: String,bimId: String,completion: @escaping (Bool,String) -> Void)
{
    let url = car_URL.urlPre + "OurBim/requestXr"
    let parms = ["appliId":bimId,"plateType":"3","token":token,"versionId": car_cloudarInfo.arversion()]
    print(url)
    print(parms)
    request = AF.request(url,method:.post,parameters: parms).response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data())
            let json = jsonObject as? [String:Any]
            if let code = json?["code"] as? Int,
               let msg = json?["message"] as? String,
               let data = json?["data"] as? [String:Any]
            {
                print(json)
                if code == 0 {
                    if let taskID = data["taskId"] as? String,
                       let hostID = data["hostID"] as? String,
                       let publicIP = data["publicIp"] as? String
                    {
                        car_UserInfo.taskID = taskID
                        car_UserInfo.hostID = hostID
                        car_UserInfo.cloudarIP = publicIP
                        completion(true,"success")
                    } else {
                        completion(false,"not found url or taskid")
                    }
                }else {
                    completion(false,msg)
                }
            } else {
                completion(false,(json?["message"] as? String)!)
            }
        case .failure(_):
            completion(false,"response fail")
        }
    }
}
