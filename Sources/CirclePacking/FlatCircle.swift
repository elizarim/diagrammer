import Foundation

public struct FlatCircle: Circle, Equatable {
    public var radius: CircleRadius
    public var center: Point

    public init(radius: CircleRadius, center: Point) {
        self.radius = radius
        self.center = center
    }
}
