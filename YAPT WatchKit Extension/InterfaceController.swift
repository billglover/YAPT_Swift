//
//  InterfaceController.swift
//  YAPT WatchKit Extension
//
//  Created by Bill Glover on 25/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import WatchKit
import Foundation

// MARK: - Constants
struct ParentAppActions {
    static let interfaceUpdate = "interfaceUpdate"
    static let startStopButtonPressed = "startStopButtonPressed"
    static let actionIdentifier = "action"
}

struct ParentAppData {
    static let intervalType = "intervalType"
    static let intervalTimerState = "intervalTimerState"
    static let intervalEnd = "intervalEnd"
    static let intervalDuration = "intervalDuration"
}

class InterfaceController: WKInterfaceController {
    
    // MARK: - Interface Properties
    @IBOutlet weak var timerDetailLabel: WKInterfaceLabel!
    @IBOutlet weak var timerCounter: WKInterfaceTimer!
    @IBOutlet weak var timerInterfaceButton: WKInterfaceButton!
    @IBOutlet weak var outerGroup: WKInterfaceGroup!
    
    // MARK: - WatchKit Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        requestInterfaceUpdate()
    }

    override func willActivate() {
        super.willActivate()
        requestInterfaceUpdate()
    }

    // MARK: - User Interaction
    @IBAction func timerControlPressed() {
        signalStartStopButtonPressed()
    }
    
    // MARK: - Parrent App Communication
    func requestInterfaceUpdate() {
        var watchKitInfo: [NSObject : AnyObject] = [:]
        watchKitInfo[ParentAppActions.actionIdentifier] = ParentAppActions.interfaceUpdate
        WKInterfaceController.openParentApplication(watchKitInfo, reply: handleParentAppReply)
    }
    
    func signalStartStopButtonPressed() {
        var watchKitInfo: [NSObject : AnyObject] = [:]
        watchKitInfo[ParentAppActions.actionIdentifier] = ParentAppActions.startStopButtonPressed
        WKInterfaceController.openParentApplication(watchKitInfo, reply: handleParentAppReply)
    }
    
    func handleParentAppReply(reply: [NSObject: AnyObject]!, _error: NSError!) -> Void {
        if let reply = reply as? [String : AnyObject] {
            self.updateInterfaceWithReplyFromParentApp(reply)
        }
    }
    
    //MARK: - Update Interface
    func updateInterfaceWithReplyFromParentApp(reply: [String : AnyObject]) {
        
        // update the interface based on whether user should be working or taking a break
        if let intervalType = reply[ParentAppData.intervalType] as? Int {
            if intervalType == 0 { // work
                timerDetailLabel.setText("Focus")
            } else { // break
                timerDetailLabel.setText("Relax")
            }
        }
        
        // check if the timer is currently running
        if let intervalTimerState = reply[ParentAppData.intervalTimerState] as? Bool {
            
            // if the timer is active, then display the remaining time and set countdown
            if intervalTimerState == true {
                
                if let intervalEnd = reply[ParentAppData.intervalEnd] as? NSDate {
                    timerCounter.setDate(intervalEnd)
                    timerCounter.start()
                    
                    var localTimer = NSTimer.scheduledTimerWithTimeInterval(intervalEnd.timeIntervalSinceNow, target: self, selector: Selector("requestInterfaceUpdate"), userInfo: nil, repeats: false)
                }
            
            // or if the timer isn't running, display the interval duration
            } else {
                
                timerCounter.stop()
                if let intervalDuration = reply[ParentAppData.intervalDuration] as? NSTimeInterval {
                    let newDuration = intervalDuration + 1.0 // for some reason the counter seems to round the time remaining down by 1s
                    let intervalEnd = NSDate(timeIntervalSinceNow: newDuration)
                    timerCounter.setDate(intervalEnd)
                }
                
            }
        }
    }

}
