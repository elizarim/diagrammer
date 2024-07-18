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
    public func firstCollisionIndex(
        in circles: [FlatCircle],
        between lower: Int, _ upper: Int,
        padding: Distance = .zero
    ) -> Int? {
        guard lower < circles.count else {
          return nil
        }
        var current = lower
        while current <= upper {
          if collides(with: circles[current], padding: padding) {
            return current
          } else {
            current += 1
          }
        }
        return nil
    }

    /// Determines whether or not source circle has collision points with that circle.
    func collides(with circle: FlatCircle, padding: Distance = .zero) -> Bool {
        center.distance(to: circle.center) - radius - circle.radius < padding - .epsilon
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
    public mutating func put(nextTo peer: FlatCircle, padding: Distance = .zero) {
        center = Point(x: peer.center.x + peer.radius + radius + padding, y: peer.center.y)
    }

    /// Makes that circle tangent to source circles.
    public mutating func put(between a: FlatCircle, _ b: FlatCircle, padding: Distance = .zero) {
        let a = FlatCircle(radius: a.radius + radius + padding, center: a.center)
        let b = FlatCircle(radius: b.radius + radius + padding, center: b.center)
        center = b.collide(with: a).first!
    }
}
