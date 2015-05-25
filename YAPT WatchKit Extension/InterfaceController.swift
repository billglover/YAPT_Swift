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
    
    // MARK: - Internal Properties
    var toggle: Bool = false
    
    // MARK: - WatchKit Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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

    // MARK: - User Interaction
    @IBAction func timerControlPressed() {
        
        var watchKitInfo: [NSObject : AnyObject] = [:]
        watchKitInfo["action"] = "startStopButtonPressed"
        
        WKInterfaceController.openParentApplication(watchKitInfo, reply: {(reply, error) -> Void in
            println("\(reply)")
        })
        
        if (toggle) {
            timerInterfaceButton.setTitle("Start")
            timerCounter.setTextColor(UIColor.redColor())
        } else {
            timerInterfaceButton.setTitle("Stop")
            timerCounter.setTextColor(UIColor.blueColor())
        }
        toggle = !toggle
    }
}
