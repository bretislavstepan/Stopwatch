//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Cocoa
import CoreData

@objcMembers class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var finishMenuItem: NSMenuItem!
    @IBOutlet weak var startMenuItem: NSMenuItem!
    @IBOutlet weak var clearMenuItem: NSMenuItem!
    var statusItem: NSStatusItem!
    var stopwatch: Stopwatch!
    var timer: Timer!
    var sessions: Sessions!
    var preferencesController : PreferencesController?

    override func awakeFromNib() {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let managedObjectContext = delegate.persistentContainer.viewContext
        sessions = Sessions(context: managedObjectContext)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = statusMenu
        stopwatch = Stopwatch()
        registerForSleepWakeNotifications()
        updateDisplay()
        appendSessionsToMenuItems()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        PreferencesController(windowNibName: NSNib.Name(rawValue: "PreferencesController")).showWindow(self)
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
            timer.invalidate()
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
        
        _ = sessions.create(date: Date(), duration: Float(stopwatch.duration), label: label)
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
        statusItem.title = stopwatch.duration.formatted
        enableMenuItems()
    }
    
    private func enableMenuItems() {
        finishMenuItem.isEnabled = stopwatch.duration > 0
        startMenuItem.title = stopwatch.isRunning ? "Pause" :
            stopwatch.duration == 0 ? "Start" : "Continue"
    }
    
    private func appendSessionsToMenuItems() {
        clearSessionsFromMenuItems()

        let sessions = self.sessions.getAll()
        if sessions.isEmpty {
            return
        }

        guard let menu = statusItem.menu else { return }

        let count = menu.items.count
        
        menu.item(at: Constants.Index.separator)?.isHidden = false
        menu.item(at: count - Constants.PositionFromBottom.clearItem)?.isHidden = false
        menu.item(at: count - Constants.PositionFromBottom.exportItem)?.isHidden = false // Export...
        
        for session in sessions {
            let item = SessionMenuItem()
            item.sessionId = session.objectID
            item.title = session.title()
            item.target = self
            item.action = #selector(copySpendTime(_:))
            menu.insertItem(item, at: 4)
        }
    }
    
    private func clearSessionsFromMenuItems() {
        let menu = statusItem.menu!
        var count = menu.items.count
        
        menu.item(at: Constants.Index.separator)?.isHidden = true
        menu.item(at: count - Constants.PositionFromBottom.clearItem)?.isHidden = true
        menu.item(at: count - Constants.PositionFromBottom.exportItem)?.isHidden = true

        count -= Constants.menuItemsAfterLastSession

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
        return response == NSApplication.ModalResponse.alertFirstButtonReturn ? txt.stringValue : ""
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

    @objc func copySpendTime(_ sender: SessionMenuItem) {
        guard let id = sender.sessionId else { return }
        guard let session = sessions.getById(id) else { return }
        let spentTime = TimeInterval(Double(session.duration)).formattedForGitlab

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(spentTime, forType: NSPasteboard.PasteboardType.string)

        showNotification(title: "Stopwatch",
                         subtitle: spentTime,
                         informativeText: "Spent time has been copied to the Pasteboard.")
    }
}

extension StatusMenuController: NSUserNotificationCenterDelegate {

    func showNotification(title: String?, subtitle: String?, informativeText: String?) -> Void {
        let notification = NSUserNotification()

        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = informativeText

        NSUserNotificationCenter.default.deliver(notification)
    }

}
