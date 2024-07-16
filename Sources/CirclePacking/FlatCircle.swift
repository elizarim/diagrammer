import Foundation

public typealias CircleRadius = Distance

public struct FlatCircle: Equatable {
    public var radius: CircleRadius
    public var center: Point

    public init(radius: CircleRadius, center: Point) {
        self.radius = radius
        self.center = center
    }

    /// Returns the minimal index of the circle in the source range who collides with that circle.
    func firstCollisionIndex(
      in circles: [FlatCircle],
      between lower: Int, _ upper: Int
    ) -> Int? {
        return nil
    }

    /// Determines whether or not source circle has collision points with that circle.
    func collides(with circle: FlatCircle) -> Bool {
      center.distance(to: circle.center) - radius - circle.radius < .epsilon
    }

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
    public mutating func put(nextTo peer: FlatCircle) {
        center = Point(x: peer.center.x + peer.radius + radius, y: peer.center.y)
    }

    /// Makes that circle tangent to source circles.
    public mutating func put(between a: FlatCircle, _ b: FlatCircle) {
        let a = FlatCircle(radius: a.radius + radius, center: a.center)
        let b = FlatCircle(radius: b.radius + radius, center: b.center)
        center = a.collide(with: b).first!
    }
}
