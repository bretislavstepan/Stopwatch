//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import Foundation
import CoreData

class CsvExporter {

    func write(_ objects: [NSManagedObject], to: URL) {
        let content = createCsv(objects)
        try? content.write(to: to, atomically: true, encoding: String.Encoding.utf8)
    }
    
    fileprivate func createCsv(_ objects: [NSManagedObject]) -> String {
        guard objects.count > 0 else { return "" }
        
        let firstObject = objects[0]
        let attribs = Array(firstObject.entity.attributesByName.keys)

        let header = (attribs.reduce("", {($0 as String) + "," + $1 }) as NSString)
            .substring(from: 1) + "\n"
    
        let csv = objects.map(
            {object in (attribs.map({((object.value(forKey: $0) ?? "NIL") as AnyObject).description})
                .reduce("", {$0 + "," + $1}) as NSString)
                .substring(from: 1) + "\n"
            }).reduce("", +)
    
        return header + csv
    }
    
}
