import Foundation

/// The outer circle which is tangent to both its inner circles (pins).
public struct OuterCircle: Circle {
    public var radius: CircleRadius
    public var center: Point
    let headPin: FlatCircle
    let tailPin: FlatCircle

    /// Returns the smallest circle that contains all source circles.
    public func union(_ circles: [FlatCircle]) -> OuterCircle {
        var outerCircle = self
        while let circle = outerCircle.findExternalCircle(circles) {
            outerCircle = outerCircle.union(circle)
        }
        return outerCircle
    }

    /// Finds the circle which lies outside of that circle.
    private func findExternalCircle(_ circles: [FlatCircle]) -> FlatCircle? {
        let (circle, distance) = findMostDistantCircle(in: circles)
        return distance > .epsilon ? circle : nil
    }

    /// Returns the smallest circle that contains that and source circles.
    private func union(_ c4: FlatCircle) -> OuterCircle {
        let c1 = self, c2 = headPin, c3 = tailPin
        let cX = c2.maxDistance(to: c4) >= c3.maxDistance(to: c4) ? c2 : c3
        let o1 = c1.center, o4 = c4.center, oX = cX.center
        let m1 = oX - o1
        let m2 = o4 - o1, m2l = hypot(m2.x, m2.y), m2e = Point(x: m2.x/m2l, y: m2.y/m2l)
        let cosM1M2 = (m1.x*m2.x + m1.y*m2.y) / (hypot(m1.x, m1.y)*hypot(m2.x, m2.y))
        let a = c1.radius + c1.distanceToFarSide(of: c4) - cX.radius
        let b = oX.distance(to: o1)
        let x = (a*a - b*b) / (2*a - 2*b*cosM1M2)
        return OuterCircle(
            radius: a - x + cX.radius,
            center: Point(x: m2e.x*x, y: m2e.y*x) + o1,
            headPin: c4,
            tailPin: cX
        )
    }
}

public extension OuterCircle {
    /// Creates the outer circle with minimal radius which is tangent to both source circles.
    init(for a: FlatCircle, _ b: FlatCircle) {
        self.init(
            radius: a.maxDistance(to: b) / 2,
            center: Rect.union(a.sharedDiameterCollisionPoints(b)).center,
            headPin: a,
            tailPin: b
        )
    }
}

public extension Circle {
    /// Finds the circle whose far side is the most distant.
    func findMostDistantCircle(in circles: [FlatCircle]) -> (FlatCircle, Distance) {
        precondition(!circles.isEmpty)
        var mostDistantCircle: FlatCircle? = nil
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
    func maxDistance(to circle: some Circle) -> Distance {
        distanceToFarSide(of: circle) + radius*2
    }

    /// Returns the minimal distance to the far side of the source circle.
    func distanceToFarSide(of circle: some Circle) -> Distance {
        center.distance(to: circle.center) + circle.radius - radius
    }

    /// Returns the points where the line constructed using both that and source circles's centers collides with them.
    func sharedDiameterCollisionPoints(_ other: FlatCircle) -> [Point] {
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
