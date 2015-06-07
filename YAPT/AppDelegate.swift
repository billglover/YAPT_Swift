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
    static let handleWatchKitExtensionRequest = "handleWatchKitExtensionRequest"
}

struct NotificationActions {
    static let nextActionIdentifier = "nextActionIdentifier"
    static let abortActionIdentifier = "abortActionIdentifier"
}

struct NotificationCategories {
    static let intervalNotificationCategoryIdentifier = "intervalNotificationCategoryIdentifier"
    static let workNotificationCategory = "workNotificationCategory"
    static let breakNotificationCategory = "breakNotificationCategory"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        registerNotificationTypes()
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("didReceiveLocalNotification received. Checking for userInfo")
        if let userInfo = notification.userInfo {
            if let currentIntervalIndex: Int = userInfo["index"] as? Int {
                println("didReceiveLocalNotification: \(currentIntervalIndex)")
            }
        }
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
        
        var intervalNotificationCategory = UIMutableUserNotificationCategory()
        intervalNotificationCategory.identifier = NotificationCategories.intervalNotificationCategoryIdentifier
        intervalNotificationCategory.setActions([nextAction], forContext: UIUserNotificationActionContext.Default)

        var breakNotificationCategory = UIMutableUserNotificationCategory()
        breakNotificationCategory.identifier = NotificationCategories.breakNotificationCategory
        breakNotificationCategory.setActions([nextAction], forContext: UIUserNotificationActionContext.Default)
        
        var workNotificationCategory = UIMutableUserNotificationCategory()
        workNotificationCategory.identifier = NotificationCategories.workNotificationCategory
        workNotificationCategory.setActions([nextAction], forContext: UIUserNotificationActionContext.Default)
        
        let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: types, categories: [intervalNotificationCategory, breakNotificationCategory, workNotificationCategory])
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    // MARK: - WatchKit Extension
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        // package userInfo and the reply so we can send to the main app
        let watchKitExtensionRequestPackage = YAPTWatchKitInfo(userInfo: userInfo, reply: reply)

        // notify the main app that we have a request from the watch
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationMessages.handleWatchKitExtensionRequest, object: watchKitExtensionRequestPackage)

    }

}

