//
//  StatusMenuController.swift
//  Stopwatch
//
//  Created by Břetislav Štěpán on 14.11.17.
//  Copyright © 2017 Břetislav Štěpán. All rights reserved.
//

import Cocoa
import CoreData

class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var finishMenuItem: NSMenuItem!
    @IBOutlet weak var startMenuItem: NSMenuItem!
    @IBOutlet weak var clearMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let stopwatch = Stopwatch()
    let numberOfItemsAfterLastSessionItem = 4
    var observation: NSKeyValueObservation? = nil
    var sessions: Sessions!

    override func awakeFromNib() {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        sessions = Sessions(context: managedObjectContext)
        statusItem.menu = statusMenu
        
        observation = stopwatch.observe(\.duration, options: [.initial, .new, .old]) {
            (stopwatch, change) in self.updateDisplay()
        }
        
        appendSessionsToMenuItems()
    }
    
    @IBAction func toggle(_ sender: NSMenuItem) {
        stopwatch.toggle()
        enableMenuItems()
    }
    
    @IBAction func reset(_ sender: NSMenuItem) {
        stopwatch.reset()
    }
    
    @IBAction func finish(_ sender: NSMenuItem) {
        if stopwatch.isRunning {
            stopwatch.toggle()
        }

        _ = sessions.create(date: Date(), duration: Float(stopwatch.duration), label: "")
        sessions.saveChanges()
        appendSessionsToMenuItems()
        stopwatch.reset()
    }
    
    @IBAction func clear(_ sender: NSMenuItem) {
        for session in sessions.getAll() {
            sessions.delete(id: session.objectID);
        }
        sessions.saveChanges()
        appendSessionsToMenuItems()
    }
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func updateDisplay() {
        statusItem.title = stopwatch.duration.format()
        enableMenuItems()
    }
    
    private func enableMenuItems() {
        finishMenuItem.isEnabled = stopwatch.duration > 0
        startMenuItem.title = stopwatch.isRunning ? "Pause" :
            stopwatch.duration == 0 ? "Start" : "Continue"
    }
    
    private func appendSessionsToMenuItems() {
        clearSessionsFromMenuItems()
        
        if (sessions.getAll().count == 0) {
            return
        }
        
        let count = statusItem.menu!.items.count
        
        statusItem.menu!.item(at: 3)?.isHidden = false // separator
        statusItem.menu!.item(at: count - 3)?.isHidden = false // Clear
        
        for session in sessions.getAll() {
            let newItem : NSMenuItem = NSMenuItem(title: "\(session.duration)", action: nil, keyEquivalent: "")
            newItem.isEnabled = false
            statusItem.menu?.insertItem(newItem, at: 4)
        }
    }
    
    private func clearSessionsFromMenuItems() {
        var count = statusItem.menu!.items.count
        
        statusItem.menu!.item(at: 3)?.isHidden = true // separator
        statusItem.menu!.item(at: count - 4)?.isHidden = true // Clear

        count -= numberOfItemsAfterLastSessionItem

        if count < 4 {
            return
        }
        
        for i in (4 ... count) {
            statusItem.menu?.removeItem(at: i)
        }
    }


}
