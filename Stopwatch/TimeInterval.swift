//
//  TimeInterval.swift
//  Stopwatch
//
//  Created by Břetislav Štěpán on 15.11.17.
//  Copyright © 2017 Břetislav Štěpán. All rights reserved.
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
