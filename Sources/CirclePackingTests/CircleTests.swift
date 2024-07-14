//
//  File.swift
//  
//
//  Created by Pavel Osipov on 14.07.2024.
//

import XCTest
@testable import CirclePacking

class CircleTests: XCTestCase {
    func testPutNearMethod() {
        let a = FlatCircle(radius: 20, center: Point(x: 1, y: 2))
        var b = FlatCircle(radius: 10, center: .zero)
        b.put(nextTo: a)
        XCTAssertEqual(b, FlatCircle(radius: 10, center: Point(x: 31, y: 2)))
    }

    func testCollisionPoints() {
        let a = FlatCircle(radius: 50, center: Point(x: -25, y: 0))
        let b = FlatCircle(radius: 50, center: Point(x:  25, y: 0))
        let points = a.collide(with: b).rounded(floatingPoints: 0)
        XCTAssertEqual(points.first, Point(x: 0, y: 43))
        XCTAssertEqual(points.second, Point(x: 0, y: -43))
    }

    func testPutBetweenMethod() {
        let a = FlatCircle(radius: 20, center: Point(x: -25, y: 0))
        var b = FlatCircle(radius: 20, center: .zero)
        b.put(nextTo: a)
        var c = FlatCircle(radius: 20, center: .zero)
        c.put(between: b, a)
//        XCTAssertEqual(c.center.rounded(floatingPoints: 0), Point(x: 0, y: 43))
    }
}
