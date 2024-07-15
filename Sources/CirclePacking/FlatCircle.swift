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
        center = Point(x: peer.center.x + peer.radius + radius, y: peer.center.y)
    }

    /// Makes that circle tangent to source circles.
    mutating func put(between a: FlatCircle, _ b: FlatCircle) {
        let a = FlatCircle(radius: a.radius + radius, center: a.center)
        let b = FlatCircle(radius: b.radius + radius, center: b.center)
        center = a.collide(with: b).first!
    }
}
