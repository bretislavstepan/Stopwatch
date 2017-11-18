//
//  Stopwatch.swift
//  Stopwatch
//
//  Created by Břetislav Štěpán on 14.11.17.
//  Copyright © 2017 Břetislav Štěpán. All rights reserved.
//

import Cocoa

@objcMembers class Stopwatch: NSObject {

    dynamic public private(set) var duration: TimeInterval = 0
    
    public private(set) var isRunning = false
    
    private var timer = Timer()
    
    func toggle() {
        isRunning ? timer.invalidate() : scheduleTimer()
        isRunning = !isRunning
    }
    
    private func scheduleTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc internal func update() {
        duration += 1
    }

    func reset() {
        duration = 0
    }
    
}
