//
//  SwiftExtensions.swift
//  YAPT
//
//  Created by Bill Glover on 30/05/2015.
//  Copyright (c) 2015 Bill Glover. All rights reserved.
//

import Foundation

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
