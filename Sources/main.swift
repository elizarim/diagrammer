typealias Distance = FloatType

struct Point {
    var x: Distance
    var y: Distance

    static var zero: Point { Point(x: .zero, y: .zero) }

    static prefix func - (p: Point) -> Point { Point(x: -p.x, y: -p.y) }

    static func - (a: Point, b: Point) -> Point { Point(x: a.x - b.x, y: a.y - b.y) }
    static func -= (lhs: inout Point, rhs: Point) { lhs = lhs - rhs }

    // static func + (a: Point, b: Point) -> Point { ... }
    // static func += (lhs: inout Point, rhs: Point) { ... }

    // static func *= (p: inout Point, m: Distance)
    // static func /= (p: inout Point, d: Distance)

    // func distance(to point: Point) -> Distance { ... }
}

struct Size {
    var width: Distance
    var height: Distance

    static var zero: Size { Size(width: .zero, height: .zero) }
}

struct Rect {
    var origin: Point
    var size: Size

    static var zero: Rect { Rect(origin: .zero, size: .zero) }

    // var center: Point { ... }

    /// Returns the smallest rectangle that contains all source points.
    // static func union(_ points: [Point]) -> Rect { ... }
}

let p1 = Point(x: 1, y: 1)
let p2 = Point(x: 2, y: 2)
print(p1.distance(to: p2))
