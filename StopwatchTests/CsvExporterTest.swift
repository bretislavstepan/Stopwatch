//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import XCTest
import Cocoa
@testable import Stopwatch

class CsvExporterTest: XCTestCaseWithMemoryManagedObjectContext {

    let exporter = CsvExporter()
    var fileURL: URL?

    override func setUp() {
        super.setUp()
        let fileName = String(format: "%@_%@", NSUUID().uuidString, "export.csv")
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: fileURL!)
    }

    func dataProvider() -> [NSManagedObject] {
        let sessions = [
            [10.0, 1.0, "Some description label"],
            [100.0, 59.0, "Another label"],
        ]

        return sessions.map({
            (value: Array) -> (NSManagedObject) in
            let entity =  NSEntityDescription.entity(forEntityName: "Session", in: self.context!)
                let session = NSManagedObject(entity: entity!, insertInto:context) as! SessionMO
                session.duration = Float(value[0] as! Double)
                session.date = Date.init(timeIntervalSince1970: value[1] as! TimeInterval)
                session.label = value[2] as? String
                return session
        })
    }

    func testCreatingEmptyCsv() {
        XCTAssertNotNil(context)
        XCTAssertNotNil(fileURL)

        guard let fileURL = fileURL else { return }

        exporter.write([], to: fileURL);
        let csv = try? String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertEqual(csv, "")
    }

    func testCreatingCsv() {
        XCTAssertNotNil(context)
        XCTAssertNotNil(fileURL)

        guard let fileURL = fileURL else { return }

        exporter.write(dataProvider(), to: fileURL);
        let csv = try? String(contentsOf: fileURL, encoding: .utf8)

        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "export", ofType: "csv")!
        let expectedCsv = try! String(contentsOfFile: path)

        XCTAssertEqual(csv, expectedCsv)
    }

}
