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


    static func *= (p: inout Point, m: Distance) { 
        p.x *= m 
        p.y *= m 
    }
    static func /= (p: inout Point, d: Distance) {
        p.x /= d
        p.y /= d
    }

    func distance(to point: Point) -> Distance {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
        
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

    var center: Point {
        Point(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }

    static func union(points: [Point]) -> Rect {
        guard !points.isEmpty else {
            return .zero
        }
        var minX = points[0].x
        var maxX = points[0].x
        var minY = points[0].y
        var maxY = points[0].y
        for point in points {
            if point.x < minX { 
                minX = point.x 
            }
            if point.x > maxX { 
                maxX = point.x 
            }
            if point.y < minY { 
                minY = point.y 
            }
            if point.y > maxY {
                maxY = point.y 
            }
        }
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }
}

let p1 = Point(x: 1, y: 1)
let p2 = Point(x: 2, y: 2)
print(p1.distance(to: p2))

let rect = Rect.union(points: [])
