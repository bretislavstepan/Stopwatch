//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT
//

import Cocoa
import CoreData

@objcMembers class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var finishMenuItem: NSMenuItem!
    @IBOutlet weak var startMenuItem: NSMenuItem!
    @IBOutlet weak var clearMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let stopwatch = Stopwatch()
    let numberOfItemsAfterLastSessionItem = 7
    var timer: Timer?
    var sessions: Sessions!
    var preferencesController : PreferencesController?

    override func awakeFromNib() {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        sessions = Sessions(context: managedObjectContext)
        statusItem.menu = statusMenu
        registerForSleepWakeNotifications()
        updateDisplay()
        appendSessionsToMenuItems()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesController = PreferencesController(windowNibName: NSNib.Name(rawValue: "PreferencesController"))
        preferencesController?.showWindow(self)
    }

    @IBAction func aboutStopwatchClicked(_ sender: NSMenuItem) {
        NSApplication.shared.orderFrontStandardAboutPanel()
    }

    @IBAction func toggle(_ sender: NSMenuItem) {
        stopwatch.toggle()
        updateDisplay()
        if stopwatch.isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDisplay), userInfo: nil, repeats: true)
        }
        else {
            if let timer = timer {
                timer.invalidate()
            }
        }
        
        enableMenuItems()
    }
    
    @IBAction func reset(_ sender: NSMenuItem) {
        stopwatch.reset()
    }
    
    @IBAction func finish(_ sender: NSMenuItem) {
        if stopwatch.isRunning {
            stopwatch.toggle()
        }
        
        let label = getLabel(title: "Stopwatch", question: "Enter the session label:")
        
        _ = sessions.create(date: Date(), duration: Float(stopwatch.getDuration()), label: label)
        sessions.saveChanges()
        appendSessionsToMenuItems()
        stopwatch.stop()
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
    
    @objc func updateDisplay() {
        statusItem.title = stopwatch.getDuration().format()
        enableMenuItems()
    }
    
    private func enableMenuItems() {
        finishMenuItem.isEnabled = stopwatch.getDuration() > 0
        startMenuItem.title = stopwatch.isRunning ? "Pause" :
            stopwatch.getDuration() == 0 ? "Start" : "Continue"
    }
    
    private func appendSessionsToMenuItems() {
        clearSessionsFromMenuItems()
        
        if (sessions.getAll().count == 0) {
            return
        }
        
        let count = statusItem.menu!.items.count
        
        statusItem.menu!.item(at: 3)?.isHidden = false // separator
        statusItem.menu!.item(at: count - 5)?.isHidden = false // Clear
        statusItem.menu!.item(at: count - 6)?.isHidden = false // Export...
        
        for session in sessions.getAll() {
            let newItem = NSMenuItem(title: session.title(), action: nil, keyEquivalent: "")
            newItem.isEnabled = false
            statusItem.menu?.insertItem(newItem, at: 4)
        }
    }
    
    private func clearSessionsFromMenuItems() {
        var count = statusItem.menu!.items.count
        
        statusItem.menu!.item(at: 3)?.isHidden = true // separator
        statusItem.menu!.item(at: count - 5)?.isHidden = true // Clear
        statusItem.menu!.item(at: count - 6)?.isHidden = true // Export...

        count -= numberOfItemsAfterLastSessionItem

        if count < 4 {
            return
        }
        
        for i in (4 ... count).reversed() {
            statusItem.menu?.removeItem(at: i)
        }
    }

    private func getLabel(title: String, question: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "Save session")
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        txt.isSelectable = true
        msg.accessoryView = txt

        let response: NSApplication.ModalResponse = msg.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            return txt.stringValue
        }
        return ""
    }

    @IBAction func export(_ sender: NSMenuItem) {
        let panel = NSSavePanel();
        panel.allowedFileTypes = ["csv"]
        panel.allowsOtherFileTypes = false
        panel.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                let exporter = CsvExporter()
                exporter.write(self.sessions.getAll(), to: panel.url!)
            }
        }
    }
}
