import Foundation

typealias Distance = FloatType

struct Point {
    var x: Distance
    var y: Distance

    static var zero: Point { Point(x: .zero, y: .zero) }

    static prefix func - (p: Point) -> Point { Point(x: -p.x, y: -p.y) }

    static func - (a: Point, b: Point) -> Point { Point(x: a.x - b.x, y: a.y - b.y) }
    static func -= (lhs: inout Point, rhs: Point) { lhs = lhs - rhs }

    static func + (a: Point, b: Point) -> Point { Point(x: a.x + b.x, y: a.y + b.y) }
    static func += (lhs: inout Point, rhs: Point) { lhs = lhs + rhs }

    static func *= (p: inout Point, m: Distance) { p.x *= m; p.y *= m }
    static func /= (p: inout Point, d: Distance) { p.x /= d; p.y /= d }

    func distance(to point: Point) -> Distance {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
