//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Foundation

class Stopwatch {

    private var duration: TimeInterval = 0
    
    public private(set) var isRunning = false
    public private(set) var isActive = false
    
    private var timer = Timer()
    
    private var startTime: Date?
    
    func toggle() {
        if isRunning {
            duration -= startTime?.timeIntervalSinceNow ?? 0
        }
        else {
            startTime = Date()
            isActive = true
        }

        isRunning = !isRunning
    }

    func reset() {
        duration = 0
        startTime = Date()
    }
    
    func stop() {
        isActive = false
        isRunning = false
        duration = 0
        startTime = nil
    }
    
    func getDuration() -> TimeInterval {
        if isRunning {
            return duration - (startTime?.timeIntervalSinceNow ?? 0)
        }
        return duration
    }
    
}
