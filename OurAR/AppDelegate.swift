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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        createAppWindow()
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
}

