import Foundation

public typealias Distance = FloatType

public struct Point: Equatable {
    public var x: Distance
    public var y: Distance

    public init(x: Distance, y: Distance) {
        self.x = x
        self.y = y
    }

    public static var zero: Point { Point(x: .zero, y: .zero) }

    public static prefix func - (p: Point) -> Point { Point(x: -p.x, y: -p.y) }

    public static func - (a: Point, b: Point) -> Point { Point(x: a.x - b.x, y: a.y - b.y) }
    public static func -= (lhs: inout Point, rhs: Point) { lhs = lhs - rhs }

    public static func + (a: Point, b: Point) -> Point { Point(x: a.x + b.x, y: a.y + b.y) }
    public static func += (lhs: inout Point, rhs: Point) { lhs = lhs + rhs }

    public static func *= (p: inout Point, m: Distance) { p.x *= m; p.y *= m }
    public static func /= (p: inout Point, d: Distance) { p.x /= d; p.y /= d }

    func distance(to point: Point) -> Distance { hypot(x - point.x, y - point.y) }
}
