import Foundation

typealias CircleRadius = Distance

struct FlatCircle: Equatable {
    var radius: CircleRadius
    var center: Point

    /// Determines shared points for both that and source circles.
    func collide(with circle: FlatCircle) -> Points {
        let r1 = radius
        let r2 = circle.radius
        let c = circle.center - center // Shift origin of coordinates to the center of that circle
        let line = Line(
            a: -2*c.x,
            b: -2*c.y,
            c: c.x*c.x + c.y*c.y + r1*r1 - r2*r2
        )
        return line.collideCircle(with: radius) + center // Shift back origin of coordinates
    }

    /// Places that circle to the right of the source circle.
    mutating func put(nextTo peer: FlatCircle) {
    }

    /// Makes that circle tangent to source circles.
    mutating func put(between a: FlatCircle, _ b: FlatCircle) {
    }
}
