//
//  AppDelegate.swift
//  OurAR
//
//  Created by lee on 2023/7/4.
//

import UIKit
import CloudAR

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var allowRotation = Bool()
    var window: UIWindow?
    private var hasShownLoginAlert = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        car_UserInfo.userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        car_UserInfo.imgUrl = UserDefaults.standard.string(forKey: "imgUrl") ?? ""
        car_UserInfo.name = UserDefaults.standard.string(forKey: "userName") ?? "匿名"
        
        createAppWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginExpiredNotification), name: Notification.Name("OANetworkUnauthorized"), object: nil)
        
        return true
    }
    
    func createAppWindow() {
        self.window = UIWindow(frame:UIScreen.main.bounds)
        self.window?.rootViewController = UITabBarController()
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if getIsIphone() {
            if allowRotation {
                return .landscapeRight
            }
            return .portrait
        }else {
            return .all
        }
    }
    
    @objc func loginExpiredNotification() {
        guard !hasShownLoginAlert else { return }
        hasShownLoginAlert = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let rootVC = self.window?.rootViewController else { return }
            let presentingVC = self.topViewController(from: rootVC)
            
            let alert = UIAlertController(title: "提示",
                                          message: "该账号验证信息已失效，请重新登录",
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { _ in
                // 10秒后允许再次弹窗
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.hasShownLoginAlert = false
                }
                self.jumpToLogin()
            }
            alert.addAction(ok)
            
            presentingVC.present(alert, animated: true)
        }
    }
    
    func topViewController(from base: UIViewController) -> UIViewController {
        if let nav = base as? UINavigationController {
            return topViewController(from: nav.visibleViewController ?? nav)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(from: selected)
            }
        }
        
        if let presented = base.presentedViewController {
            return topViewController(from: presented)
        }
        
        return base
    }
    
    func jumpToLogin() {
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "imgUrl")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        car_UserInfo.userID = ""
        car_UserInfo.name = ""
        car_UserInfo.imgUrl = ""
        
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate {
            sceneDelegate.switchToLogin()
        }

    }
}

