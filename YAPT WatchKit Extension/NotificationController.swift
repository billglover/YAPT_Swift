//
//  NotificationController.swift
//  YAPT WatchKit Extension
//
//  Created by Bill Glover on 25/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var notificationDetailLabel: WKInterfaceLabel!
    
    let breakColor = UIColor(red: 48/255.0, green: 119/255.0, blue: 198/255.0, alpha: 1.0)
    let workColor = UIColor(red: 194/255, green: 49/255.0, blue: 52/255.0, alpha: 1.0)
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        
        if let userInfo = localNotification.userInfo as? [String: AnyObject] {
            if let index = userInfo["index"] as? Int {
                notificationDetailLabel.setText("Interval \(index) is now complete.")
            }
        }
       
        completionHandler(.Custom)
    }
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.

        notificationDetailLabel.setText("Hello from a dynamic notification")
        completionHandler(.Custom)
    }
    
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        
        if identifier != nil {
            
            if identifier == "nextActionIdentifier" {
                var watchKitInfo: [NSObject : AnyObject] = [:]
                watchKitInfo["action"] = "startStopButtonPressed"
                WKInterfaceController.openParentApplication(watchKitInfo, reply: nil)
            }
            
        }
    }
}
