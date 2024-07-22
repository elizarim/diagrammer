import Foundation

/// The outer circle which is tangent to both its inner circles (pins).
struct OuterCircle: Circle {
    var radius: CircleRadius
    var center: Point
    let headPin: FlatCircle
    let tailPin: FlatCircle

    /// Returns the smallest circle that contains all source circles.
    func union(_ circles: [FlatCircle]) -> OuterCircle {
        fatalError()
    }

    /// Finds the circle which lies outside of that circle.
    private func findExternalCircle(_ circles: [FlatCircle]) -> FlatCircle? {
        fatalError()
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

extension OuterCircle {
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

extension Circle {
    /// Finds the circle whose far side is the most distant.
    func findMostDistantCircle(in circles: [FlatCircle]) -> (FlatCircle, Distance) {
        fatalError()
    }

    /// Returns the distance between far sides of both that and source circles.
    func maxDistance(to circle: some Circle) -> Distance {
        fatalError()
    }

    /// Returns the minimal distance to the far side of the source circle.
    func distanceToFarSide(of circle: some Circle) -> Distance {
        fatalError()
    }

    /// Returns the points where the line constructed using both that and source circles's centers collides with them.
    func sharedDiameterCollisionPoints(_ other: FlatCircle) -> [Point] {
        fatalError()
    }

    /// Returns the points where the line constructed using both circle's center and external point collides with that circle.
    func diameterCollisionPoints(passing externalPoint: Point) -> Points {
        fatalError()
    }
}
