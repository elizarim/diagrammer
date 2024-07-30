import Foundation

public typealias CircleRadius = Distance

public protocol Circle {
    var radius: CircleRadius { get }
    var center: Point { get set }
}

public extension Circle {
    /// Returns the minimal index of the circle in the source range who collides with that circle.
    func firstCollisionIndex(
        in circles: [Circle],
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
    func collides(with circle: Circle, padding: Distance = .zero) -> Bool {
        center.distance(to: circle.center) - radius - circle.radius < padding - .epsilon
    }

    /// Determines shared points for both that and source circles.
    func collide(with circle: Circle) -> Points {
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
    mutating func put(nextTo peer: Circle, padding: Distance = .zero) {
        center = Point(x: peer.center.x + peer.radius + radius + padding, y: peer.center.y)
    }

    /// Makes that circle tangent to source circles.
    mutating func put(between a: Circle, _ b: Circle, padding: Distance = .zero) {
        let a = FlatCircle(radius: a.radius + radius + padding, center: a.center)
        let b = FlatCircle(radius: b.radius + radius + padding, center: b.center)
        center = b.collide(with: a).first!
    }

    /// Finds the circle whose far side is the most distant.
    func findMostDistantCircle(in circles: [Circle]) -> ( Circle, Distance) {
        precondition(!circles.isEmpty)
        var mostDistantCircle: Circle? = nil
        var maxDistance = -Distance.infinity
        for circle in circles {
            let distance1 = distanceToFarSide(of: circle)
            if distance1 > maxDistance {
                maxDistance = distance1
                mostDistantCircle = circle
            }
        }
        return (mostDistantCircle!, maxDistance)
    }

    /// Returns the distance between far sides of both that and source circles.
    func maxDistance(to circle: Circle) -> Distance {
        distanceToFarSide(of: circle) + radius*2
    }

    /// Returns the minimal distance to the far side of the source circle.
    func distanceToFarSide(of circle: Circle) -> Distance {
        center.distance(to: circle.center) + circle.radius - radius
    }

    /// Returns the points where the line constructed using both that and source circles's centers collides with them.
    func sharedDiameterCollisionPoints(_ other: Circle) -> [Point] {
        let bPoints = other.diameterCollisionPoints(passing: center)
        let aPoints = diameterCollisionPoints(passing: other.center)
        return [bPoints.first!, bPoints.second!, aPoints.first!, aPoints.second!]
    }

    /// Returns the points where the line constructed using both circle's center and external point collides with that circle.
    func diameterCollisionPoints(passing externalPoint: Point) -> Points {
        let p = externalPoint - center
        return Line(a: p.y, b: -p.x, c: 0).collideCircle(with: radius) + center
    }
}
