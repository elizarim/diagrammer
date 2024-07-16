import Foundation

public struct Size: Equatable {
    var width: Distance
    var height: Distance

    static var zero: Size { Size(width: .zero, height: .zero) }
}

public struct Rect: Equatable {
    var origin: Point
    var size: Size

    static var zero: Rect { Rect(origin: .zero, size: .zero) }

    var center: Point {
        Point(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }

    static func union(_ points: [Point]) -> Rect {
        guard !points.isEmpty else {
            return .zero
        }
        var minX = points[0].x
        var maxX = points[0].x
        var minY = points[0].y
        var maxY = points[0].y
        for point in points {
            if point.x < minX { 
                minX = point.x 
            }
            if point.x > maxX { 
                maxX = point.x 
            }
            if point.y < minY { 
                minY = point.y 
            }
            if point.y > maxY {
                maxY = point.y 
            }
        }
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }
}
