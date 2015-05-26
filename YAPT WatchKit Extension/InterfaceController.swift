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
        
        WKInterfaceController.openParentApplication(watchKitInfo, reply: { [unowned self](reply, error) -> Void in
            
            if let reply = reply as? [String : AnyObject] {
            
                if let currentIntervalType = reply["currentIntervalType"] as? String {
                    self.timerDetailLabel.setText(currentIntervalType)
                }
                
                if let currentIntervalEndTime = reply["currentIntervalEndTime"] as? NSDate {
                    self.timerCounter.setDate(currentIntervalEndTime)
                    
                    if let timerState = reply["timerState"] as? Bool {
                        if timerState {
                            self.timerInterfaceButton.setTitle("Stop")
                            self.timerCounter.start()
                        } else {
                            self.timerInterfaceButton.setTitle("Start")
                            self.timerCounter.stop()
                        }
                    }
                }
                
                if let red = reply["currentIntervalColorRed"] as? CGFloat {
                    
                    if let green = reply["currentIntervalColorGreen"] as? CGFloat {
                     
                        if let blue = reply["currentIntervalColorBlue"] as? CGFloat {
                         
                            if let alpha = reply["currentIntervalColorAlpha"] as? CGFloat {
                                
                                var color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                                self.timerCounter.setTextColor(color)
                                self.timerInterfaceButton.setBackgroundColor(color)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            
            println("\(reply)")
        })
    }
}
