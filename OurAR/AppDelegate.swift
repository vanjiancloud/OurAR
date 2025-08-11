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
        } else {
            if allowRotation {
                return .landscapeRight
            }
            return .portrait
        }
    }
    
    @objc func loginExpiredNotification() {
        guard !hasShownLoginAlert else { return }
        hasShownLoginAlert = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 更安全的获取 keyWindow 方式
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                  let rootVC = window.rootViewController else {
                return
            }
            
            let presentingVC = self.safeTopViewController(from: rootVC)
            print("最终用于 present 的 VC: \(String(describing: presentingVC))")
            
            // 检查是否已有弹窗
            if presentingVC.presentedViewController != nil {
                print("已有弹窗存在，不再重复显示")
                return
            }
            
            let alert = UIAlertController(title: "提示",
                                        message: "该账号验证信息已失效，请重新登录",
                                        preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.hasShownLoginAlert = false
                }
                self.jumpToLogin()
            }
            alert.addAction(ok)
            
            presentingVC.present(alert, animated: true)
        }
    }

    // 更安全的顶层控制器获取方法
    func safeTopViewController(from base: UIViewController) -> UIViewController {
        // 1. 处理导航控制器
        if let nav = base as? UINavigationController {
            return safeTopViewController(from: nav.visibleViewController ?? nav)
        }
        
        // 2. 处理标签栏控制器（适配没有 selectedViewController 的情况）
        if let tab = base as? UITabBarController {
            // 优先使用 selectedViewController
            if let selected = tab.selectedViewController {
                return safeTopViewController(from: selected)
            }
            // 如果没有选中的，使用第一个子控制器
            else if let first = tab.viewControllers?.first {
                return safeTopViewController(from: first)
            }
            // 如果连子控制器都没有，返回 tabBarController 本身
            return tab
        }
        
        // 3. 处理模态弹出的控制器
        if let presented = base.presentedViewController {
            return safeTopViewController(from: presented)
        }
        
        // 4. 默认返回 base
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

