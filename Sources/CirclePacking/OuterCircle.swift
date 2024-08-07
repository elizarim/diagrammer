import Foundation

/// The outer circle which is tangent to both its inner circles (pins).
public struct OuterCircle: Circle {
    public var radius: CircleRadius
    public var center: Point
    let headPin: Circle?
    let tailPin: Circle?
    let padding: Distance

    /// Returns the smallest circle that contains all source circles.
    public func union(_ circles: [Circle], padding: Distance) -> OuterCircle {
        var outerCircle = self
        while let circle = outerCircle.findExternalCircle(circles, padding: padding) {
            outerCircle = outerCircle.union(circle, padding: padding)
        }
        return outerCircle
    }

    /// Finds the circle which lies outside of that circle.
    private func findExternalCircle(_ circles: [Circle], padding: Distance) -> Circle? {
        let (circle, distance) = findMostDistantCircle(in: circles)
        return distance > .epsilon ? circle : nil
    }

    /// Returns the smallest circle that contains that and source circles.
    private func union(_ c4: Circle, padding: Distance = .zero) -> OuterCircle {
        let c1 = self, c2 = headPin!, c3 = tailPin!
        let cX = c2.maxDistance(to: c4) >= c3.maxDistance(to: c4) ? c2 : c3
        let o1 = c1.center, o4 = c4.center, oX = cX.center
        let m1 = oX - o1
        let m2 = o4 - o1, m2l = hypot(m2.x, m2.y), m2e = Point(x: m2.x/m2l, y: m2.y/m2l)
        let cosM1M2 = (m1.x*m2.x + m1.y*m2.y) / (hypot(m1.x, m1.y)*hypot(m2.x, m2.y))
        let a = c1.radius + c1.distanceToFarSide(of: c4) - cX.radius
        let b = oX.distance(to: o1)
        let x = (a*a - b*b) / (2*a - 2*b*cosM1M2)
        return OuterCircle(
            radius: a - x + cX.radius + padding,
            center: Point(x: m2e.x*x, y: m2e.y*x) + o1,
            headPin: c4,
            tailPin: cX,
            padding: padding
        )
    }
}

public extension OuterCircle {
    /// Creates the outer circle with minimal radius which is tangent to both source circles.
    init(for a: Circle?, _ b: Circle?, padding: Distance) {
        if let circleA = a, let circleB = b {
            self.radius = circleA.maxDistance(to: circleB) / 2 + padding
            self.center = Rect.union(circleA.sharedDiameterCollisionPoints(circleB)).center
            self.headPin = circleA
            self.tailPin = circleB
            self.padding = padding
        } else if let circle = a ?? b {
            self.radius = circle.radius + padding
            self.center = circle.center
            self.headPin = circle
            self.tailPin = nil
            self.padding = padding
        } else {
            self.radius = padding
            self.center = .zero
            self.headPin = nil
            self.tailPin = nil
            self.padding = padding
        }
    }
}
