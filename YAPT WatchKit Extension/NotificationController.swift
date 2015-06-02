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

    // we are only using the static notification interface so pass .Default to the completion handler
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        completionHandler(.Default)
    }
    
}
