//
//  Copyright © 2017 Břetislav Štěpán.
//  Licensed under MIT.
//

import XCTest
@testable import Stopwatch

class StopwatchTests: XCTestCase {

    let stopwatch = Stopwatch()
    
    func testMeasuring() {
        XCTAssertEqual(false, stopwatch.isActive)

        XCTAssertEqual(0, stopwatch.getDuration())
        stopwatch.toggle() // START
        XCTAssertEqual(true, stopwatch.isRunning)
        XCTAssertEqual(true, stopwatch.isActive)

        sleep(5)

        stopwatch.toggle() // PAUSE
        XCTAssertEqual(false, stopwatch.isRunning)
        XCTAssertEqual(true, stopwatch.isActive)

        sleep(5)

        stopwatch.toggle() // CONTINUE
        XCTAssertEqual(true, stopwatch.isRunning)
        XCTAssertEqual(true, stopwatch.isActive)

        sleep(5)

        stopwatch.reset()
        XCTAssertEqual(true, stopwatch.getDuration() < 1)
        XCTAssertEqual(true, stopwatch.isRunning)
        XCTAssertEqual(true, stopwatch.isActive)

        sleep(5)

        stopwatch.toggle() // pause
        XCTAssertEqual(true, stopwatch.getDuration() > 0)

        stopwatch.stop()

        XCTAssertEqual(0, stopwatch.getDuration())
        XCTAssertEqual(false, stopwatch.isRunning)
        XCTAssertEqual(false, stopwatch.isActive)
    }
    
}
