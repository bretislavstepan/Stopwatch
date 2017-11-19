//
//  Stopwatch.swift
//  Stopwatch
//
//  Created by Břetislav Štěpán on 14.11.17.
//  Copyright © 2017 Břetislav Štěpán. All rights reserved.
//

import Cocoa

class Stopwatch: NSObject {

    private var duration: TimeInterval = 0
    
    public private(set) var isRunning = false
    
    private var timer = Timer()
    
    private var startTime: Date?
    
    func toggle() {
        if isRunning {
            duration -= startTime?.timeIntervalSinceNow ?? 0
        }
        else {
            startTime = Date()
        }

        isRunning = !isRunning
    }

    func reset() {
        duration = 0
        startTime = Date()
    }
    
    func getDuration() -> TimeInterval {
        if isRunning {
            return duration - (startTime?.timeIntervalSinceNow ?? 0)
        }
        return duration
    }
    
}
