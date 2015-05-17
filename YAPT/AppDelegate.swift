//
//  AppDelegate.swift
//  YAPT
//
//  Created by Bill Glover on 09/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import UIKit

struct NotificationMessages {
    static let applicationWillTerminate = "applicationWillTerminate"
    static let applicationDidBecomeActive = "applicationDidBecomeActive"
    static let applicationWillEnterForeground = "applicationWillEnterForeground"
    static let applicationDidEnterBackground = "applicationDidEnterBackground"
    static let applicationWillResignActive = "applicationWillResignActive"
    static let notificationActionNextInterval = "notificationActionNextInterval"
}

struct NotificationActions {
    static let nextActionIdentifier = "nextActionIdentifier"
    static let abortActionIdentifier = "abortActionIdentifier"
}

struct NotificationCategories {
    static let intervalNotificationCategoryIdentifier = "intervalNotificationCategoryIdentifier"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // register our Notification settings
        registerNotificationTypes()
        
        // decision to clear all notifications if the user force quits the application
        /*
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                if let userInfo = notification.userInfo {
                    if let currentIntervalIndex: Int = userInfo["index"] as? Int {
                        println("didFinishLaunchingWithOptions: \(currentIntervalIndex)")
                    }
                }
            }
        }
        */
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            if let currentIntervalIndex: Int = userInfo["index"] as? Int {
                println("didReceiveLocalNotification: \(currentIntervalIndex)")
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.applicationWillResignActive, object: self)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.applicationDidEnterBackground, object: self)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.applicationWillEnterForeground, object: self)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.applicationDidBecomeActive, object: self)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.applicationWillTerminate, object: self)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let actionIdentifier = identifier {
            switch actionIdentifier {
            case NotificationActions.nextActionIdentifier:
                if let userInfo = notification.userInfo {
                    if let currentIntervalIndex: Int = userInfo["index"] as? Int {
                        println("didReceiveLocalNotification: \(currentIntervalIndex) and triggered the next interval")
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.notificationActionNextInterval, object: self)
                    }
                }
            case NotificationActions.abortActionIdentifier:
                if let userInfo = notification.userInfo {
                    if let currentIntervalIndex: Int = userInfo["index"] as? Int {
                        println("didReceiveLocalNotification: \(currentIntervalIndex) and abandoned the run")
                    }
                }
            default:
                println("unkown notificationa action received")
            }
        }
        completionHandler()
    }

    func registerNotificationTypes() {
        var nextAction = UIMutableUserNotificationAction()
        nextAction.identifier = NotificationActions.nextActionIdentifier
        nextAction.title = "Next Interval"
        nextAction.activationMode = UIUserNotificationActivationMode.Background
        nextAction.destructive = false
        nextAction.authenticationRequired = false
        
        var abortAction = UIMutableUserNotificationAction()
        abortAction.identifier = NotificationActions.abortActionIdentifier
        abortAction.title = "Abandon"
        abortAction.activationMode = UIUserNotificationActivationMode.Background
        abortAction.destructive = true
        abortAction.authenticationRequired = false
        
        var intervalNotificationCategory = UIMutableUserNotificationCategory()
        intervalNotificationCategory.identifier = NotificationCategories.intervalNotificationCategoryIdentifier
        intervalNotificationCategory.setActions([nextAction, abortAction], forContext: UIUserNotificationActionContext.Default)
        
        
        let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: types, categories: [intervalNotificationCategory])
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }

}

