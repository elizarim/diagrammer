import XCTest
@testable import CirclePacking

private let sin45 = (sqrt(2)/2.0).rounded(floatingPoints: 2)

class LineTests: XCTestCase {
    func testMultiCollisionDetection() {
        let line = Line(a: 1, b: -1, c: 0) // y = x
        let points = line.collideCircle(with: 1).rounded(floatingPoints: 2)
        XCTAssertEqual(points.first, -Point(x: sin45, y: sin45))
        XCTAssertEqual(points.second, Point(x: sin45, y: sin45))
    }

    func testSingleCollisionDetection() {
        let line = Line(a: 1, b: -1, c: 2*sqrt(2)/2) // y = x + 2*sin(π/4)
        let points = line.collideCircle(with: 1).rounded(floatingPoints: 2)
        XCTAssertEqual(points.first, Point(x: -sin45, y: sin45))
        XCTAssertEqual(points.second, nil)
    }

    func testNoCollisionDetection() {
        let line = Line(a: 1, b: -1, c: 2) // y = x + 2
        let points = line.collideCircle(with: 1)
        XCTAssertEqual(points.first, nil)
        XCTAssertEqual(points.second, nil)
    }
}
