//
//  AppDelegate.swift
//  CoinDuel
//
//  Created by Anish Chadalavada on 1/25/18.
//  Copyright © 2018 Capitalize. All rights reserved.
//
// Facebook code from https://www.simplifiedios.net/facebook-login-swift-3-tutorial/

import UIKit
import OneSignal
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Source: https://stackoverflow.com/questions/26753925/set-initial-viewcontroller-in-appdelegate-swift

        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyName = UserDefaults.standard.string(forKey:"authToken") != nil ? "Main" : "Login"
        let controllerName = UserDefaults.standard.string(forKey:"authToken") != nil ? "LandingPageViewController" : "EntryViewController"
        
        let storyboard = UIStoryboard(name: storyName, bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: controllerName)
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "044ab786-f216-4f2f-9508-cddd3ec69cbd",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
//        OneSignal.setEmail("example@domain.com");

        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        // Based on Facebook login example at https://www.simplifiedios.net/facebook-login-swift-3-tutorial/
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        // Based on Facebook login example at https://www.simplifiedios.net/facebook-login-swift-3-tutorial/
        FBSDKAppEvents.activateApp()
    }
    
    // Based on Facebook login example at https://www.simplifiedios.net/facebook-login-swift-3-tutorial/
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

