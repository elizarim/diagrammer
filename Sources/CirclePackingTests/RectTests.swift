import XCTest
@testable import CirclePacking

class RectTests: XCTestCase {
    func testCenter() {
        var rect = Rect.zero
        rect.origin = Point(x: 1, y: 2)
        rect.size = Size(width: 10, height: 20)
        XCTAssertEqual(rect.center, Point(x: 6, y: 12))
    }

    func testUnion() {
        XCTAssertEqual(Rect.union([]), Rect.zero)
        XCTAssertEqual(Rect.union(Array(repeating: Point.zero, count: 10)), Rect.zero)
        XCTAssertEqual(
            Rect.union(Array(repeating: Point(x: 1, y: 2), count: 10)),
            Rect(origin: Point(x: 1, y: 2), size: .zero)
        )
        XCTAssertEqual(
            Rect.union([Point(x: 1, y: 2), Point(x: -1, y: -2)]),
            Rect(origin: Point(x: -1, y: -2), size: Size(width: 2, height: 4))
        )
        XCTAssertEqual(
            Rect.union([Point(x: -1, y: -2), Point(x: 1, y: 2)]),
            Rect(origin: Point(x: -1, y: -2), size: Size(width: 2, height: 4))
        )
    }
}
