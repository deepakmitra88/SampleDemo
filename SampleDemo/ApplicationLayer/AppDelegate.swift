//
//  AppDelegate.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var isServerReachable = Bool()
    var serverReachability = Reachability()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.configureReachability()
        self.createDocumentPath()
        // Override point for customization after application launch.
        return true
    }
    
    func configureReachability() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kNetworkReachabilityChangedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name(rawValue: "kNetworkReachabilityChangedNotification"), object: nil)
        
        serverReachability = Reachability.forInternetConnection()
        serverReachability.startNotifier()
        updateInterfaceWithReachability(curReach: serverReachability)
    }
    
    func reachabilityChanged(note:NSNotification) {
        let curReach:Reachability = note.object as! Reachability
        assert(curReach.isKind(of:Reachability.self))
        self.updateInterfaceWithReachability(curReach: curReach)
    }
    
    func updateInterfaceWithReachability(curReach:Reachability) {
        let netStatus:NetworkStatus = curReach.currentReachabilityStatus()
        switch netStatus {
        case NotReachable:
            isServerReachable = false
            print(isServerReachable)
            break
        default:
            isServerReachable = true
            print(isServerReachable)
            break
        }
    }
    
    func createDocumentPath() {
        let directoryPath = getDocumentPath()
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
    }
    
    func getDocumentPath()->String {
        let directoryPath =  NSHomeDirectory().appending("/Documents/").appending("DemoFiles/")
        return directoryPath
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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

