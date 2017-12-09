//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Foundation

class Stopwatch {

    private var startTime = Date()
    private var counter: TimeInterval = 0
    public private(set) var isRunning = false
    public private(set) var isActive = false
    public var duration: TimeInterval {
        get {
            return isRunning ? counter - startTime.timeIntervalSinceNow : counter
        }
    }

    func toggle() {
        if isRunning {
            counter -= startTime.timeIntervalSinceNow
        }
        else {
            startTime = Date()
            isActive = true
        }

        isRunning = !isRunning
    }

    func reset() {
        counter = 0
        startTime = Date()
    }
    
    func stop() {
        isActive = false
        isRunning = false
        counter = 0
    }
    
}
