//
//  InterfaceController.swift
//  YAPT WatchKit Extension
//
//  Created by Bill Glover on 25/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import WatchKit
import Foundation

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
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        requestInterfaceUpdate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - User Interface
    @IBAction func timerControlPressed() {
        signalStartStopButtonPressed()
    }
    
    func updateInterfaceWithReplyFromParentApp(reply: [String : AnyObject]) {
        
        println("reply: \(reply)")
        
        // update the interface based on whether user should be working
        // or taking a break
        if let intervalType = reply["intervalType"] as? Int {
            if intervalType == 0 { // work
                timerDetailLabel.setText("Focus")
            } else if intervalType == 1 { // break
                timerDetailLabel.setText("Relax")
            }
        }
        
        // check if the timer is currently running
        if let intervalTimerState = reply["intervalTimerState"] as? Bool {
            if intervalTimerState == true {
                
                // update the time remaining
                if let intervalEnd = reply["intervalEnd"] as? NSDate {
                    timerCounter.setDate(intervalEnd)
                    timerCounter.start()
                    
                    // set a local timer to ensure the interface updates when we hit 0
                    var localTimer = NSTimer.scheduledTimerWithTimeInterval(intervalEnd.timeIntervalSinceNow, target: self, selector: Selector("requestInterfaceUpdate"), userInfo: nil, repeats: false)
                    
                }
                
                
            } else {

                timerCounter.stop()
                if let intervalDuration = reply["intervalDuration"] as? NSTimeInterval {
                    
                    // for some reason the counter seems to round the time remaining down by 1s
                    let newDuration = intervalDuration + 1.0
                    let intervalEnd = NSDate(timeIntervalSinceNow: newDuration)
                    timerCounter.setDate(intervalEnd)
                }
                
            }
        }

    }
    
    func handleParentAppReply(reply: [NSObject: AnyObject]!, _error: NSError!) -> Void {
        if let reply = reply as? [String : AnyObject] {
            self.updateInterfaceWithReplyFromParentApp(reply)
        }
    }
    
    func requestInterfaceUpdate() {
        var watchKitInfo: [NSObject : AnyObject] = [:]
        watchKitInfo["action"] = "interfaceUpdate"
        WKInterfaceController.openParentApplication(watchKitInfo, reply: handleParentAppReply)
    }
    
    func signalStartStopButtonPressed() {
        var watchKitInfo: [NSObject : AnyObject] = [:]
        watchKitInfo["action"] = "startStopButtonPressed"
        WKInterfaceController.openParentApplication(watchKitInfo, reply: handleParentAppReply)
    }
}
