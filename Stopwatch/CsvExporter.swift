//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT
//

import Foundation
import CoreData

class CsvExporter {

    func write(_ objects: [NSManagedObject], to: URL) {
        let content = createContent(objects)
        try? content.write(to: to, atomically: true, encoding: String.Encoding.utf8)
    }
    
    fileprivate func createContent(_ objects: [NSManagedObject]) -> String {
        guard objects.count > 0 else {
            return ""
        }
        
        let firstObject = objects[0]
        let attribs = Array(firstObject.entity.attributesByName.keys)
        let header = (attribs.reduce("", {($0 as String) + "," + $1 }) as NSString)
            .substring(from: 1) + "\n"
    
        let csvArray = objects.map({object in
            (attribs
                .map({((object.value(forKey: $0) ?? "NIL") as! NSManagedObject).description})
                .reduce("", {$0 + "," + $1})
            as NSString)
                .substring(from: 1) + "\n"
        })
        
        let csv = csvArray.reduce("", +)
    
        return header + csv
    }
    
}
