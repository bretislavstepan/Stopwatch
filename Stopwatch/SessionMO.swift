//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Foundation

extension SessionMO {
    
    func title() -> String {
        let dateString = formattedDate()
        let durationString = formattedTimeInterval()
        var labelString = formattedLabel()
        
        if labelString.count > 0 {
            labelString = ": \(labelString)"
        }
        
        return "\(dateString) – \(durationString)\(labelString)";
    }
    
    func formattedLabel() -> String {
        return label ?? ""
    }
    
    func formattedDate() -> String {
        guard let date = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func formattedTimeInterval() -> String {
        return TimeInterval(duration).formatted
    }

}
