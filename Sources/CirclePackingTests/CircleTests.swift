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
      b.put(nextTo: a, padding: 8)
      XCTAssertEqual(b, FlatCircle(radius: 10, center: Point(x: 39, y: 2)))
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
      b.put(nextTo: a, padding: 10)
      var c = FlatCircle(radius: 20, center: .zero)
      c.put(between: b, a, padding: 10)
      XCTAssertEqual(c.center.rounded(floatingPoints: 0), Point(x: 0, y: -43))
      XCTAssertFalse([a, b, c].hasCollisions())
    }

    func testCollisionDetection() {
      let a = FlatCircle(radius: 2, center: Point(x: 0, y: 2))
      XCTAssertTrue(a.collides(with: a))
      let b = FlatCircle(radius: 2, center: Point(x: 0, y: -2))
      XCTAssertFalse(a.collides(with: b) || b.collides(with: a))
      let c = FlatCircle(radius: 2, center: Point(x: 0, y: 1))
      let d = FlatCircle(radius: 2, center: Point(x: 0, y: -1))
      XCTAssertTrue(c.collides(with: d) && d.collides(with: c))
    }

    func testCollisionIndexDetection() {
      let a = FlatCircle(radius: 2, center: .zero)
      let b = FlatCircle(radius: 2, center: Point(x: 6, y: 0))
      let c = FlatCircle(radius: 2, center: Point(x: 4, y: 0))
      let d = FlatCircle(radius: 1, center: Point(x: 2, y: 0))
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 5, 6), nil)
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 0, 2), 2)
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 1, 2), 2)
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 2, 1), nil)
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 0, 0), nil)
      XCTAssertEqual(a.firstCollisionIndex(in: [b, c, d], between: 0, 1), nil)
    }
}
