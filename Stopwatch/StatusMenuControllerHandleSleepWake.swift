//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT
//

import Cocoa

extension StatusMenuController {

    func registerForSleepWakeNotifications() {
        let nc = NSWorkspace.shared.notificationCenter
        let dnc = DistributedNotificationCenter.default
        
        nc.addObserver(self, selector: #selector(onSleep), name: NSWorkspace.willSleepNotification, object: nil)
        nc.addObserver(self, selector: #selector(onWake), name: NSWorkspace.didWakeNotification, object: nil)
        dnc.addObserver(self, selector: #selector(onSleep), name: NSNotification.Name(rawValue: "com.apple.screensaver.didstart"), object: nil)
        dnc.addObserver(self, selector: #selector(onWake), name: NSNotification.Name(rawValue: "com.apple.screensaver.didstop"), object: nil)
        dnc.addObserver(self, selector: #selector(onSleep), name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
        dnc.addObserver(self, selector: #selector(onWake), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
    }
    
    func onSleep() {
        if stopwatch.isActive && stopwatch.isRunning {
            stopwatch.toggle()
        }
    }
    
    func onWake() {
        if stopwatch.isActive && !stopwatch.isRunning {
            stopwatch.toggle()
        }
    }
}
