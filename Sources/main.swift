import Foundation

public typealias CircleRadius = Distance

struct Points {
    var first: Point?
    var second: Point?

    static func + (a: Points, b: Point) -> Points {
        Points(first: a.first.map { $0 + b }, second: a.second.map { $0 + b })
    }
}

/// Represents line in general form A\*x + B\*y + C = 0.
struct Line {
    let a: FloatType
    let b: FloatType
    let c: FloatType

    init(a: FloatType, b: FloatType, c: FloatType) {
        precondition(abs(a) > 0 || abs(b) > 0)
        self.a = a
        self.b = b
        self.c = c
    }

    /// Locates collision points with circle which center is located at the origin of coordinates.
    func collideCircle(with radius: CircleRadius) -> Points {
        return Points()
    }
}

let rect = Rect.union(points: [])
