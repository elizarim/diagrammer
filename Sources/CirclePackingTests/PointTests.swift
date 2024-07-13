import XCTest
@testable import CirclePacking

class PointTests: XCTestCase {
    func testOperators() {
        var a = Point(x: 10, y: 10)
        let b = Point(x: 2, y: 3)
        XCTAssertEqual(a + b, Point(x: 12, y: 13))
        XCTAssertEqual(a - b, Point(x: 8, y: 7))
        XCTAssertEqual(b - a, Point(x: -8, y: -7))
        var c = Point.zero
        c += Point(x: 4, y: 6)
        XCTAssertEqual(c, Point(x: 4, y: 6))
        XCTAssertEqual(-c, Point(x: -4, y: -6))
        c -= Point(x: 5, y: 6)
        XCTAssertEqual(c, Point(x: -1, y: 0))
        a *= 2
        XCTAssertEqual(a, Point(x: 20, y: 20))
        a /= 2
        XCTAssertEqual(a, Point(x: 5, y: 5))
    }
}
