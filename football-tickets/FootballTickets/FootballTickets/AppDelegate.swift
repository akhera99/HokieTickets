//
//  AppDelegate.swift
//  BarcodeScanner
//
//  Created by Sameer Dandekar on 2/15/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import UIKit
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        readAccountDataFile()
        
        //readTicketDataFile()
        
        // This function is given in ScanFocusRegion.swift
        createScanFocusRegionImage()
        
        // TESTING
//        getRequestData()
//        attemptLogin(user: "hokipoki", pass: "pass")
        
        postRequestData2(user: "nathanmk", action: "available_tickets")
//        postRequestData(user: "nathanmk", action: "available_tickets")
        postRequestData3(user: "nathanmk", action: "get_tickets")
//        postRequestData(user: "nathanmk", action: "get_tickets")
        postRequestData(user: "nathanmk", action: "user_balance")

        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        /*
        **************************************************
        Write account data file just before app terminates
        **************************************************
        */
        writeAccountDataFile()
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
}
 
 
