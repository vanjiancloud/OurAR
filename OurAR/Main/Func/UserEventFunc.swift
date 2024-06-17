//
//  EventFunc.swift
//  OurAR
//
//  Created by lee on 2023/7/6.
//

import Foundation
import CloudAR
import Alamofire

//------------------------------------------------
//MARK: 一级功能触发的统一通道

func sendEventMainToolOpen(main: MainToolType,params:[String:Any] = [:],completion: @escaping (Bool) -> Void) {
    var valid = false
    switch main {
    case.MainView:
        valid =  true
        moveToMainView() { result in completion(result)}
        break
    case .PersonView:
        break
    case .GouJianShu:
        break
    case .ShuXing:
        break
    case .Celiang:
        break
    case .BiaoQian:
        //标签开启好像有标签显示的命令
        valid = true
        controlTagShow(show: true) {result in completion(result)}
        break
    case .KeJianXing:
        break
    case .FenJie:
        break
    case .PouQie:
        break
    }
    if !valid {
        completion(true)
    }
}

func sendEventMainToolClose(main: MainToolType,params: [String:Any] = [:],completion: @escaping (Bool) -> Void) {
    var valid = false
    switch main {
    case .MainView:
        break
    case .PersonView:
        break
    case .GouJianShu:
        break
    case .ShuXing:
        break
    case .Celiang:
        valid = true
        closeMeasurement() { result in completion(result)}
        break
    case .BiaoQian:
        //标签关闭也有关闭事件
        valid = true
        controlTagShow(show: false) { result in completion(result)}
        break
    case .KeJianXing:
        break
    case .FenJie:
        break
    case .PouQie:
        break
    }
    if !valid {
        completion(true)
    }
}

//EndMark
//------------------------------------------------

//------------------------------------------------
//MARK: start
//二级功能触发开启的统一通道
/**
 params: 主要是为了
 */
func sendEventBySecondTypes(main: MainToolType,seconds: [SecondToolType],params: [String:Any],completion: @escaping (Bool,String) -> Void) {
    //没有二级菜单就不需要考虑
    var valid = false
    print("--main:\(main)--seconds:\(seconds)--params:\(params)")
    switch main {
    case .MainView:
        break
    case .PersonView:
        if seconds.count == 1 {
            valid = true
            sendEventOfPersonView(type: seconds[0],params: params) { result,msg in completion(result,"")}
        }
        break
    case .GouJianShu: //没有二级菜单
        break
    case .ShuXing: //没有二级菜单
        break
    case .Celiang:
        //测量只能存在一个secondToolType
        if seconds.count == 1 {
            valid = true
            sendEventOfCeLiang(type: seconds[0],params: params) { result in completion(result,"")}
        }
    case .BiaoQian:
        break
        
    case .KeJianXing:
        if seconds.count == 1 {
            valid = true
            sendEventOfKeJianXing(type: seconds[0],params: params) { result,msg in completion(result,msg)}
        }
        break
    case .FenJie:
        break
    case .PouQie:
        break
    }
    if !valid {
        completion(true,"")
    }
}

fileprivate func sendEventOfPersonView(type: SecondToolType,params:[String:Any],completion: @escaping (Bool,String) -> Void) {
    switch type {
    case .PVT(.FP):
        doAction(type: .FP) { result,msg  in completion(result,msg)}
        break
    case .PVT(.TP):
        doAction(type: .TP) { result,msg in completion(result,msg)}
        break
    default:
        completion(false,"")
        break
    }
}

fileprivate func sendEventOfKeJianXing(type: SecondToolType,params:[String:Any],completion: @escaping (Bool,String) -> Void) {
    switch type {
    case .KJX(.yincang):
        conChoiceVisible(type: .yincang) { result,msg  in completion(result,msg)}
        break
    case .KJX(.geli):
        invertHidden(type: .geli) { result,msg in completion(result,msg)}
        break
    case .KJX(.xianshiquanbu):
        displayAllActor(type: .xianshiquanbu) { result,msg in completion(result,msg)}
        break
    default:
        completion(false,"")
        break
    }
}

fileprivate func sendEventOfCeLiang(type: SecondToolType,params:[String:Any],completion: @escaping (Bool) -> Void) {
    switch type {
    case .MMT(.distace):
        measurement(type: .distace) { result in completion(result)}
        break
    case .MMT(.coordinate):
        measurement(type: .coordinate) { result in completion(result)}
        break
    case .MMT(.angle):
        measurement(type: .angle) { result in completion(result)}
        break
    case .MMT(.changePrecisionOrUnit):
        if let unit = params["unit"] as? MeasureUnitType,
           let precision = params["precision"] as? MeasurePrecisionType {
            changeMeasureUnit(unit: unit, precision: precision) { result in completion(result)}
        } else {
            print("\(#function),changeprecisionOrUnit,not found unit or precision")
            completion(false)
        }
    default:
        completion(false)
        break
    }
}
//MARK: end
//-------------------------------------------------


//MARK: 针对返回code=0为成功的async resp
func asyncRespBool(result: Result<Data?,AFError>) -> (Bool,String) {
    switch result {
    case .success(let data):
        if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
           let json = jsonObject as? [String:Any],
           let code = json["code"] as? Int,
           let msg  = json["message"] as? String
        {
            if code == 0 {
                return (true,"")
            } else {
                return (false,msg)
            }
        }
        break
    case .failure(let error):
        return (false,String(describing: error))
    }
    return (false,"\(#function)")
}

//MARK: 移到主视图
fileprivate func moveToMainView(completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=cameraPosAll"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 人称
fileprivate func doAction(type: PersonViewType,completion: @escaping (Bool,String) -> Void) {
    let viewMode = type == .FP ? "2" : "1"
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=switchViewMode&viewMode=\(viewMode)&projectionMode=1"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}

//MARK: 隐藏图元
fileprivate func conChoiceVisible(type: KeJianXingType,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/conChoiceVisible?taskid=\(car_UserInfo.taskID)&visible=false"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}

//MARK: 隔离图元
fileprivate func invertHidden(type: KeJianXingType,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/invertHidden?taskId=\(car_UserInfo.taskID)"
    AF.request(url,method:.post).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}

//MARK: 显示全部图元
fileprivate func displayAllActor(type: KeJianXingType,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/displayAllActor?taskId=\(car_UserInfo.taskID)"
    AF.request(url,method:.post
    ).response { (response: AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        completion(isSuccess,msg)
    }
}

//MARK: 进行测量
fileprivate func measurement(type: MeasurementType,completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=\(String(describing: type))"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 关闭测量
fileprivate func closeMeasurement(completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=endMeasure"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 更改测量单位和精度
/**
 unit: m / cm / mm / in / ft
 precision:  0 / 0.1 / 0.01
 */
fileprivate func changeMeasureUnit(unit: MeasureUnitType,precision: MeasurePrecisionType,completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=changePrecisionOrUnit&unit=\(unit.rawValue)&precision=\(precision.rawValue)"
    AF.request(url,method:.get).response { (response: AFDataResponse ) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 针对后端返回的数据进行统一的第一步处理: 提取出data字段
fileprivate func asyncRespJsonToAny(result: Result<Data?,AFError>) -> Result<Any,Error> {
    switch result {
    case .success(let data):
        if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
           let json = jsonObject as? [String:Any],
           let code = json["code"] as? Int,
           let msg = json["message"] as? String {
            if code == 0 {
                if let d = json["data"] {
                    return .success(d)
                } else {
                    return .failure(car_FError.customError(message: "not found data"))
                }
            } else {
                return .failure(car_FError.customError(message: msg))
            }
        } else {
            return .failure(car_FError.customError(message: "数据响应失败"))
        }
    case .failure(let error):
        return .failure(error)
    }
}

//MARK: 显示标签
func controlTagShow(show: Bool,completion: @escaping (Bool) -> Void) {
    //https://api.OurBim.com:11022/vjapi/tagControl/controlTagShow?taskId=1146373527096524800&lableVisibility=true
    let url = car_URL.urlPre + "tagControl/controlTagShow?taskId=\(car_UserInfo.taskID)&lableVisibility=\(show)"
    AF.request(url,method: .post).response { (response: AFDataResponse) in
        print("control tag show: \(show)")
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 获取标签列表
/**
    success: [[String:Any]]  标签数组
    failed: error
 */
func queryTagList(tagGroupID: String,completion: @escaping (Result<[[String:Any]],Error>) -> Void) {
    let url = car_URL.urlPre + "tagControl/getTagList?tagId=\(tagGroupID)&appId=\(car_UserInfo.currProID)"
    AF.request(url,method:.get).response { (response: AFDataResponse ) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg  = json["message"] as? String
            {
                if code == 0 {
                    if let result = json["data"] as? [[String:Any]] {
                        completion(.success(result))
                    } else {
                        completion(.failure(car_FError.customError(message: msg)))
                    }
                    
                } else {
                    print(msg)
                    completion(.failure(car_FError.customError(message: "msg")))
                }
            }
        case .failure(let error):
            print(error)
            completion(.failure(error))
        }
    }
}

//MARK: 创建标签
/*
  string: tagid
 */
func createTagFile(tagGroupID: String,completion: @escaping (Result<String,Error>) -> Void) {
    let url = car_URL.urlPre + "tagControl/addTag"
    var info: [String:Any] = ["taskId":"\(car_UserInfo.taskID)"]
    if !tagGroupID.isEmpty {
        info["tagGroupId"] = tagGroupID
    }
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response { (response:AFDataResponse) in
        switch response.result {
        case .success(let data):
            if let jsonObject = try? JSONSerialization.jsonObject(with: data ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let msg = json["message"] as? String {
               if code == 0 {
                    if let id = json["data"] as? String {
                        completion(.success(id))
                    }
               } else {
                   completion(.failure(car_FError.customError(message: msg)))
               }
            } else {
                completion(.failure(car_FError.customError(message: "数据响应失败")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

//MARK: 创建标签组
func createTagFolder(tagGroupID: String,completion: @escaping (Result <String,Error>) ->Void) {
    let url = car_URL.urlPre + "tagControl/addTagGroup"
    var info: [String:Any] = [:]
    info["taskId"] = car_UserInfo.taskID
    if !tagGroupID.isEmpty {
        info["tagGroupId"] = tagGroupID
    }
    AF.request(url,method:.post,parameters:info,encoding: URLEncoding.default).response{ (response:AFDataResponse) in
        let result = asyncRespJsonToAny(result: response.result)
        
        switch result {
        case .success(let any):
            if let id = any as? String {
                completion(.success(id))
            } else {
                completion(.failure(car_FError.customError(message: "convert data to tagId failed")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
        
    }
}

//MARK: 修改标签名
func updateTagName(tagID: String,name: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "tagControl/updateTag"
    var info: [String:Any] = ["taskId":car_UserInfo.taskID]
    info["tagId"] = tagID
    info["tagName"] = name
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        let (success,msg) = asyncRespBool(result: response.result)
        completion(success,msg)
    }
}

//MARK: 删除标签/标签组
func deleteTag(tagID: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "tagControl/deleteTag"
    let info: [String:Any] = ["tagId": tagID,"taskId":car_UserInfo.taskID]
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        let (success,msg) = asyncRespBool(result: response.result)
        completion(success,msg)
    }
}

//MARK: 定位标签/标签组
func handelTagFocusAction(tagID: String,completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "tagControl/clickTag?"
    let info: [String:Any] = ["tagId": tagID,"taskId":car_UserInfo.taskID]
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        print(response.result)
        let (success,msg) = asyncRespBool(result: response.result)
        completion(success,msg)
    }
}

//MARK: 获取构件列表
/**
 uuid: 获得该id下的子列表
 */
func queryComponentList(uuid: String,appliId: String = car_UserInfo.currProID,completion: @escaping (Result<[[String:Any]],Error>) -> Void) {
    let url = car_URL.urlPre + "appli/getComponent?appliId=\(appliId)&uuid=\(uuid)"
    AF.request(url,method:.get).response {(response:AFDataResponse) in
        let result = asyncRespJsonToAny(result: response.result)
        switch result {
        case .success(let any):
            if let result = any as? [[String:Any]] {
                completion(.success(result))
            } else {
                completion(.failure(car_FError.customError(message: "not found data")))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

//MARK: Focus普通构件
func sendFocusModel(uuid: String,appliId: String = car_UserInfo.currProID,isFoucs: Bool,completion: @escaping (Bool) ->Void) {
    //https://api.OurBim.com:11022/vjapi/OurBim/doAction?taskid=1139943772189097984&projectId=BIM2021101814063750&mn=vanjian2&action=selectComponent
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&projectId=\(appliId)&mn=\(uuid)&action=\(isFoucs ? "selectComponent" : "cancelSelectComponen")"
    AF.request(url,method:.get).response {(response:AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        print("focus model: \(msg)")
        completion(isSuccess)
    }
}
//MARK: Focus自定义构件
func sendFocusCostomModel(uuid: String,isFoucs: Bool,completion: @escaping (Bool) ->Void) {
    let url = car_URL.urlPre + "comControl/comFocus"
    var info: [String:Any] = ["taskId": car_UserInfo.taskID]
    info["comId"] = uuid
    info["flag"] = "\(isFoucs)"
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response{(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 隐藏模型
func sendHiddenModel(uuid: String,appliId: String = car_UserInfo.currProID,isHidden: Bool,completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "OurBim/doAction"
    var info: [String:Any] = ["taskid": car_UserInfo.taskID]
    info["projectId"] = appliId
    info["action"] = isHidden ? "hideComponents" : "showComponents"
    info["mn"] = uuid == "god" ? "vanjian" : uuid
    AF.request(url,method:.get,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        let (isSuccess,msg) = asyncRespBool(result: response.result)
        print("hidden model msg: \(msg)")
        completion(isSuccess)
    }
}
//MARK: 隐藏自定义构件
func sendHiddenCustomModel(uuid: String,isHidden: Bool,completion: @escaping (Bool) -> Void) {
    let url = car_URL.urlPre + "comControl/controlComShowOrHide"
    var info: [String:Any] = ["taskId": car_UserInfo.taskID]
    info["comId"] = uuid
    info["lableVisibility"] = !isHidden
    AF.request(url,method:.post,parameters: info,encoding: URLEncoding.default).response{(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 删除自定义构件
func sendDeleteCustomModel(uuid: String,completion: @escaping (Bool) ->Void) {
//https://api.OurBim.com:11022/vjapi/comControl/deleteCom?taskId=1134892989282254848&comId=BE31E5DD405B492D45AF578875A8240D
    let url = car_URL.urlPre + "comControl/deleteCom"
    var info:[String:Any] = ["taskId":car_UserInfo.taskID]
    info["comId"] = uuid
    AF.request(url,method: .post,parameters: info,encoding: URLEncoding.default).response{(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 模型退出
func sendModelQuit(completion: @escaping (Bool,String) -> Void) {
    let url = car_URL.urlPre + "OurBim/closeOurbim?taskId=\(car_UserInfo.taskID)"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        switch response.result {
        case .success(let JSON): do {
            if let jsonObject = try? JSONSerialization.jsonObject(with: JSON ?? Data()),
               let json = jsonObject as? [String:Any],
               let code = json["code"] as? Int,
               let message = json["message"] as? String
            {
                completion(true,message)
            }
        }
        case .failure(let Error):
            completion(false,"关闭失败")
            print("query model close failed, \(Error)")
        }
    }
}

func requestExitByHostId(completion: @escaping (Bool) -> Void) {
    let url = car_URL.xrUrlPre + "v1/StartupInsByProjectId?ProjectId=&SenderId=123456&HostId=\(car_UserInfo.hostID)&nonce=\(arc4random())&tag=ar&mode=reload"
    AF.request(url,method:.get).response { (response: AFDataResponse) in
        switch response.result {
        case .success(_): do {
            completion(true)
        }
        case .failure(let Error):
            completion(false)
            print("query model close failed, \(Error)")
        }
    }
}

func sendModelQuit(screenType: car_ScreenMode) {
    switch screenType {
    case .AR:
        let url = car_URL.xrUrlPre + "v1/ShutDownTask?SenderId=\(car_UserInfo.senderID)&HostId=\(car_UserInfo.hostID)&nonce=\(arc4random())&taskid=\(car_UserInfo.taskID)"
        AF.request(url,method:.get).response { (_: AFDataResponse) in
        }
    case .ThreeD:
        //TODO: 
        break
    case .None:
        break
    }
}

//MARK: 分解
func sendFenJie(value: Int,completion: @escaping (Bool) ->Void) {
    //https://api.OurBim.com:11022/vjapi/OurBim/doAction?taskid=1136964760961548288&action=splitModel&splitValue=4
    let url = car_URL.urlPre + "OurBim/doAction?taskid=\(car_UserInfo.taskID)&action=splitModel&splitValue=\(value)"
    AF.request(url,method:.get).response {(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}

//MARK: 删除项目
func sendDeleteProject(projectID: String,completion: @escaping(Bool) -> Void) {
    let url = car_URL.urlPre + "appli/deleteProject"
    let info: [String:Any] = ["appliId":projectID,"userid":car_UserInfo.userID]
    AF.request(url,method: .post,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}
//MARK: 修改项目
func sendModifyProject(projectID: String,name: String,completion: @escaping(Bool) -> Void) {
    let url = car_URL.urlPre + "appli/updateProject"
    let info: [String:Any] = ["appid":projectID,"appName":name]
    AF.request(url,method: .post,parameters: info,encoding: URLEncoding.default).response {(response:AFDataResponse) in
        let (isSuccess,_) = asyncRespBool(result: response.result)
        completion(isSuccess)
    }
}
