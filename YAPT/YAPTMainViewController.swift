//
//  YAPTMainViewController.swift
//  YAPT
//
//  Created by Bill Glover on 09/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import UIKit

extension NSTimeInterval {
    var inHours: Double { return self.inMinutes/60 }
    var inMinutes: Double { return self/60 }
    var inSeconds: Double { return self }
    var inHoursMinutesSeconds: (hours: Double, minutes: Double, seconds: Double) {
        let hours: Double = floor(round(self) / 60 / 60)
        let minutes: Double = trunc((round(self) - (hours * 60 * 60)) / 60)
        let seconds: Double = trunc(round(self) - minutes * 60)
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
    var inMinutesSeconds: (minutes: Double, seconds: Double) {
        let minutes: Double = floor(round(self) / 60)
        let seconds: Double = trunc(round(self) - minutes * 60)
        return (minutes: minutes, seconds: seconds)
    }
}

class YAPTMainViewController: UIViewController {

    // MARK: - Types
    private enum IntervalType { case Work, Break }
    private typealias Interval = (type:IntervalType, duration:Double)
    
    // MARK: - UI Properties
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet var timerView: UIView!
    var breakColor = UIColor(red: 48/255.0, green: 119/255.0, blue: 198/255.0, alpha: 1.0)
    var workColor = UIColor(red: 194/255, green: 49/255.0, blue: 52/255.0, alpha: 1.0)
    
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

    // MARK: - Timer Methods
    private func startTimer() {
        println("startTimer() called")
        
        // set the remaining duration
        remainingIntervalDuration = schedule[currentIntervalIndex].duration
        
        // capture the start time
        currentIntervalStartTime = NSDate()
        println("intervalIndex \(currentIntervalIndex) started at \(currentIntervalStartTime)")
        
        // set up the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(timerTickInterval, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: true)
    }

    private func interruptTimer() {
        println("interruptTimer() called")
        
        // stop the timer
        timer.invalidate()
    }
    
    private func completeTimer() {
        println("completeTimer() called")
        
        // stop the timer
        timer.invalidate()
        
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
        println("resetTimer() called")
    }
    
    func timerFired() {
        println("timerFired() called at \(NSDate())")
        
        // calculate the remaining duration for this interval
        let currentTimerDuration: NSTimeInterval = currentIntervalStartTime.timeIntervalSinceNow
        remainingIntervalDuration = schedule[currentIntervalIndex].duration + currentTimerDuration
        
        // if we are out of time, complete the timer
        if round(remainingIntervalDuration) <= 0.0 {
            completeTimer()
        }
    }
    
    // MARK: - Update Display
    private func updateDisplay() {
        remainingIntervalDuration = schedule[currentIntervalIndex].duration
        updateBackground()
        updateTimerButton()
    }
    
    private func updateTimerButton() {
        if timer.valid {
            timerButton.setTitle("Stop", forState: UIControlState.Normal)
        } else {
            timerButton.setTitle("Start", forState: UIControlState.Normal)
        }
    }
    
    private func updateBackground() {
        switch schedule[currentIntervalIndex].type {
        case .Work:
            timerView.backgroundColor = workColor
        case .Break:
            timerView.backgroundColor = breakColor
        }
    }
    
    // MARK: - Navigation
    @IBAction func timerButtonPressed(sender: AnyObject) {
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
        updateTimerButton()
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
        
        // load a test schedule
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:300.0))
        schedule.append((type: IntervalType.Work, duration:1500.0))
        schedule.append((type: IntervalType.Break, duration:900.0))

        /*schedule.append((type: IntervalType.Work, duration:5.0))
        schedule.append((type: IntervalType.Break, duration:5.0))
        schedule.append((type: IntervalType.Work, duration:5.0))
        schedule.append((type: IntervalType.Break, duration:5.0))
        schedule.append((type: IntervalType.Work, duration:5.0))
        schedule.append((type: IntervalType.Break, duration:5.0))
        schedule.append((type: IntervalType.Work, duration:5.0))
        schedule.append((type: IntervalType.Break, duration:5.0))*/
        
        currentIntervalIndex = 0
        
        updateDisplay()
    }
    
    // MARK: - Notifications
    func applicationWillResignActive() {
        println("notification recieved for: applicationWillResignActive")
    }
    
    func applicationDidEnterBackground() {
        println("notification recieved for: applicationDidEnterBackground")
        
        // clear outstanding notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // set local notification for active timer
        if timer.valid {
            let currentTimerDuration: NSTimeInterval = currentIntervalStartTime.timeIntervalSinceNow
            remainingIntervalDuration = schedule[currentIntervalIndex].duration + currentTimerDuration
            
            var localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: remainingIntervalDuration)
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            switch schedule[currentIntervalIndex].type {
            case .Break:
                localNotification.alertTitle = "Break Over"
            case .Work:
                localNotification.alertTitle = "Time's Up"
            }
            localNotification.alertBody = "Interval \(currentIntervalIndex + 1) of \(schedule.count)."
            localNotification.category = NotificationCategories.intervalNotificationCategoryIdentifier
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            let userInfo:[String:Int] = ["index": currentIntervalIndex]
            localNotification.userInfo = userInfo
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
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
            timer = NSTimer.scheduledTimerWithTimeInterval(timerTickInterval, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: true)
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
    
}
