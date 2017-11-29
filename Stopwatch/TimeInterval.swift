//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Foundation

extension TimeInterval {
    
    func format() -> String {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if let formatedTimeInterval = formatter.string(from: self) {
            return formatedTimeInterval
        }
        
        return ""
    }
    
}
