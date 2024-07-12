import Foundation

typealias CircleRadius = Distance

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
        let x0 = -a*c/(a*a+b*b)
        let y0 = -b*c/(a*a+b*b)

        if c*c > radius*radius*(a*a+b*b)+EPS {
            print("no points")
        } else if abs(c*c - radius*radius*(a*a+b*b)) < EPS {
            print("1 point")
            print("\(x0) : \(y0)")
        } else {
            let d = radius*radius - c*c/(a*a+b*b)
            let mult = sqrt(d / (a*a+b*b))
            let ax = x0 + b * mult
            let bx = x0 - b * mult
            let ay = y0 - a * mult
            let by = y0 + a * mult
            print("2 points")
            print("\(ax) : \(ay) , \(bx) : \(by)")
        }
    }
}

let rect = Rect.union(points: [])
