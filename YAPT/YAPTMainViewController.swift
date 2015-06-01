//
//  YAPTMainViewController.swift
//  YAPT
//
//  Created by Bill Glover on 09/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import UIKit

class YAPTMainViewController: UIViewController {

    // MARK: - Types
    private enum IntervalType: Int { case Work, Break }
    private typealias Interval = (type:IntervalType, duration:Double)
    
    // MARK: - UI Properties
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet var timerView: UIView!
    let breakColor = UIColor(red: 48/255.0, green: 119/255.0, blue: 198/255.0, alpha: 1.0)
    let workColor = UIColor(red: 194/255, green: 49/255.0, blue: 52/255.0, alpha: 1.0)
    
    // MARK: - Properties
    private var timer = NSTimer()
    private var schedule = [Interval]()
    private let timerTickInterval: NSTimeInterval = 1.0
    private var currentIntervalStartTime = NSDate()
    private var currentIntervalIndex = 0
    private var remainingIntervalDuration: NSTimeInterval = 0.0 {
        didSet {
            timerLabel.text = String(format: "%02.0f:%02.0f", remainingIntervalDuration.inMinutesSeconds.minutes, remainingIntervalDuration.inMinutesSeconds.seconds)
        }
    }
    private var nextIntervalIndex: Int {
        get {
            return (currentIntervalIndex + 1) % schedule.count
        }
    }

    // MARK: - Timer Methods
    private func startTimer() {
        let currentInterval = schedule[currentIntervalIndex]
        remainingIntervalDuration = currentInterval.duration
        currentIntervalStartTime = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timerTickInterval, target: self, selector: Selector("timerTickEvent"), userInfo: nil, repeats: true)
        
        println("intervalIndex \(currentIntervalIndex) started at \(currentIntervalStartTime)")
    }

    private func interruptTimer() {
        timer.invalidate()
        println("intervalIndex \(currentIntervalIndex) interrupted at \(NSDate())")
    }
    
    private func completeTimer() {
        timer.invalidate()
        println("intervalIndex \(currentIntervalIndex) completed at \(NSDate())")
        
        // print some diagnostic stats
        println("target duration: \(schedule[currentIntervalIndex].duration)")
        println("actual duration: \(currentIntervalStartTime.timeIntervalSinceNow * -1)")
        
        // set the remaining duration to be zero
        remainingIntervalDuration = 0.0
        
        // advance the currentIntervalIndex or loop back to the start
        currentIntervalIndex = (currentIntervalIndex + 1) % schedule.count
        
        // toggle the timer button so that we can start again
        updateDisplay()
    }
    
    private func resetTimer() {
        println("resetTimer() called - Not Implemented")
    }
    
    func timerTickEvent() {
        let currentTimerDuration: NSTimeInterval = currentIntervalStartTime.timeIntervalSinceNow
        remainingIntervalDuration = schedule[currentIntervalIndex].duration + currentTimerDuration
        
        if round(remainingIntervalDuration) <= 0.0 {
            completeTimer()
        }
    }
    
    // MARK: - Update Display
    private func updateDisplay() {
        let currentInterval = schedule[currentIntervalIndex]
        remainingIntervalDuration = currentInterval.duration
        updateBackgroundForInterval(currentInterval)
        toggleTimerButtonForTimer(timer)
    }
    
    private func toggleTimerButtonForTimer(timer: NSTimer) {
        if timer.valid {
            timerButton.setTitle("Stop", forState: UIControlState.Normal)
        } else {
            timerButton.setTitle("Start", forState: UIControlState.Normal)
        }
    }
    
    private func updateBackgroundForInterval(interval: Interval) {
        switch interval.type {
        case .Work:
            timerView.backgroundColor = workColor
        case .Break:
            timerView.backgroundColor = breakColor
        }
    }
    
    // MARK: - Navigation
    @IBAction func timerButtonPressed() {
        if let timerButtonText = timerButton.titleLabel?.text {
            switch timerButtonText {
            case "Start":
                startTimer()
            case "Stop":
                interruptTimer()
            default:
                break
            }
        }
        toggleTimerButtonForTimer(timer)
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewDidLoad")
        
        // handle notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.applicationWillResignActive), name: NotificationMessages.applicationWillResignActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.applicationDidEnterBackground), name: NotificationMessages.applicationDidEnterBackground, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.applicationWillEnterForeground), name: NotificationMessages.applicationWillEnterForeground, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.applicationDidBecomeActive), name: NotificationMessages.applicationDidBecomeActive, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.applicationWillTerminate), name: NotificationMessages.applicationWillTerminate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.notificationActionNextInterval), name: NotificationMessages.notificationActionNextInterval, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector(NotificationMessages.handleWatchKitExtensionRequest + ":"), name: NotificationMessages.handleWatchKitExtensionRequest, object: nil)
        
        // load a test schedule
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:900.0))

//        schedule.append((type: IntervalType.Work, duration:10.0))
//        schedule.append((type: IntervalType.Break, duration:15.0))
//        schedule.append((type: IntervalType.Work, duration:5.0))
//        schedule.append((type: IntervalType.Break, duration:5.0))
//        schedule.append((type: IntervalType.Work, duration:5.0))
//        schedule.append((type: IntervalType.Break, duration:5.0))
//        schedule.append((type: IntervalType.Work, duration:5.0))
//        schedule.append((type: IntervalType.Break, duration:5.0))
        
        currentIntervalIndex = 0
        
        updateDisplay()
    }
    
    // MARK: - Notifications
    func scheduleLocalNotification() {
        if timer.valid {
            
            let currentTimerDuration: NSTimeInterval = currentIntervalStartTime.timeIntervalSinceNow
            remainingIntervalDuration = schedule[currentIntervalIndex].duration + currentTimerDuration
            
            var localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: remainingIntervalDuration)
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            // decide which notification interface to show
            switch schedule[nextIntervalIndex].type {
            case .Break:
                localNotification.alertTitle = "Time for a break"
                localNotification.category = NotificationCategories.breakNotificationCategory
                localNotification.alertBody = "Pomodoro complete, it's time to take a break."
            case .Work:
                localNotification.alertTitle = "Back to work"
                localNotification.category = NotificationCategories.workNotificationCategory
                localNotification.alertBody = "Break over, it's time to get back to work."
            }
            
            localNotification.soundName = UILocalNotificationDefaultSoundName
            let userInfo:[String:Int] = ["index": currentIntervalIndex]
            localNotification.userInfo = userInfo
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
    
    func applicationWillResignActive() {
        println("notification recieved for: applicationWillResignActive")
    }
    
    func applicationDidEnterBackground() {
        println("notification recieved for: applicationDidEnterBackground")
        
        // clear outstanding notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if timer.valid {
            
            scheduleLocalNotification()
            
            // save timer state
            var userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setInteger(currentIntervalIndex, forKey: "currentIntervalIndex")
            userDefaults.setObject(currentIntervalStartTime, forKey: "currentIntervalStartTime")
            
            // invalidate active timer
            timer.invalidate()
        }
    }
    
    func applicationWillEnterForeground() {
        println("notification recieved for: applicationWillEnterForeground")
        
        // clear outstanding notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // retrieve any saved timers
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if let startTime: NSDate = userDefaults.objectForKey("currentIntervalStartTime") as? NSDate {

            // re-establish timer details
            currentIntervalStartTime = startTime
            currentIntervalIndex = userDefaults.integerForKey("currentIntervalIndex")
            
            // re-start active timer
            timer = NSTimer.scheduledTimerWithTimeInterval(timerTickInterval, target: self, selector: Selector("timerTickEvent"), userInfo: nil, repeats: true)
        }
        
        // clear all saved timers
        userDefaults.removeObjectForKey("currentIntervalStartTime")
        userDefaults.removeObjectForKey("currentIntervalIndex")
        
    }
    
    func applicationDidBecomeActive() {
        println("notification recieved for: applicationDidBecomeActive")
    }
    
    func applicationWillTerminate() {
        println("notification recieved for: applicationWillTerminate")
        
        // clear all active timers
        timer.invalidate()
        
        // clear all notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // clear all saved timers (just to be sure)
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("currentIntervalStartTime")
        userDefaults.removeObjectForKey("currentIntervalIndex")
    }

    func notificationActionNextInterval() {
        println("notification recieved for: notificationActionNextInterval")
        completeTimer()
        startTimer()
        applicationDidEnterBackground()
    }
    
    func handleWatchKitExtensionRequest(notification: NSNotification) {
        if let watchKitExtensionRequestPackage = notification.object as? YAPTWatchKitInfo {
            
            if let action = watchKitExtensionRequestPackage.action {
                
                switch action {
                case "startStopButtonPressed":
                    println("Watch Start/Stop Button Presed")
                    timerButtonPressed()
                default:
                    break
                }
                
                watchKitExtensionRequestPackage.replyBlock(getWatchKitViewStateForInterval(schedule[currentIntervalIndex]))
            }
            
        }
    }
    
    private func getWatchKitViewStateForInterval(interval: Interval) -> [String: AnyObject] {
        /*
        This function captures the current state in a dictionary so that it can be
        sent over to the watch.
        
            intervalType: work/break
            intervalEnd: NSDate
            intervalDuration: NSTimeInterval
            intervalTimerState: bool
        */
        
        var viewStateInfo: [String: AnyObject] = [:]
        
        viewStateInfo["intervalType"] = interval.type.rawValue
        viewStateInfo["intervalEnd"] = NSDate(timeIntervalSinceNow: remainingIntervalDuration)
        viewStateInfo["intervalDuration"] = interval.duration
        viewStateInfo["intervalTimerState"] = timer.valid
        
        return viewStateInfo
    }
}
