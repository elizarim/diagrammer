public typealias FloatType = Double

extension FloatType {
  static let epsilon = FloatType(Float.ulpOfOne)
}

public enum InputNode: ExpressibleByFloatLiteral, ExpressibleByArrayLiteral {
    case branch(name: String? = nil, children: [InputNode])
    case leaf(name: String? = nil, radius: FloatType)

    public var count: Int {
        switch self {
        case let .branch(_, children):
            return children.reduce(1) { $0 + $1.count }
        case .leaf:
            return 1
        }
    }

    public init(floatLiteral value: FloatType) {
        self = .leaf(radius: value)
    }

    public init(arrayLiteral elements: InputNode...) {
        self = .branch(children: elements)
    }

    public func pack() -> CircleNode {
        switch self {
        case let .leaf(name, radius):
            let flatCircle = FlatCircle(radius: radius, center : .zero)
            return CircleNode(name: name, state: .leaf, geometry: flatCircle)
        case let .branch(name, children):
            var packedChildren = children.map { $0.pack() }
            packedChildren.orderSpatially(padding: 8)
            let outerCircle = group(packedChildren)
            for index in packedChildren.indices {
                packedChildren[index].center -= outerCircle.center
            }
            return CircleNode(
                name: name,
                state: .branch(children: packedChildren),
                geometry: FlatCircle(
                    radius: outerCircle.radius,
                    center: .zero
                )
            )
        }
    }

    private func group(_ circles: [CircleNode]) -> OuterCircle {
        switch circles.count {
        case 0:  return OuterCircle(for: nil, nil, padding: 8)
        case 1:  return OuterCircle(for: circles[0], nil, padding: 8)
        case 2:  return OuterCircle(for: circles[0], circles[1], padding: 8)
        default: return OuterCircle(for: circles[0], circles[1], padding: 8).union(circles, padding: 8)
        }
    }
}

extension CircleNode: Circle {
    public var radius: CircleRadius { geometry.radius }

    public var center: Point {
        get { geometry.center }
        set { geometry.center = newValue }
    }
}

public extension Array where Element: Circle {
    mutating func orderSpatially(padding: Distance = .zero) {
        guard count > 1 else {
            return
        }
        sort { $0.radius < $1.radius }
        self[1].put(nextTo: self[0], padding: padding)
        var pivot = 0, current = 2
        while current < count {
            let head = current - 1
            assert(pivot != head)
            var circle = self[current]
            circle.put(between: self[head], self[pivot], padding: padding)
            if let collision =
                circle.firstCollisionIndex(in: self, between: pivot + 1, head - 1, padding: padding) {
                pivot = collision
                continue
            }
            self[current] = circle
            current += 1
        }
    }
}

public extension InputNode {
    func adjustRadiuses(width: FloatType, height: FloatType) -> InputNode {
        let newRadius = min(width, height) / 2
        let currentCircle = self.pack()
        let outerCircleRadius = currentCircle.radius
        let scaleFactor = newRadius / outerCircleRadius
        return self.adjustRadiuses1(scaleFactor: scaleFactor)
    }

    private func adjustRadiuses1(scaleFactor: FloatType) -> InputNode {
        switch self {
        case let .leaf(name, radius):
            return .leaf(name: name, radius: radius * scaleFactor)
        case let .branch(name, children):
            let adjustedChildren = children.map { $0.adjustRadiuses1(scaleFactor: scaleFactor) }
            return .branch(name: name, children: adjustedChildren)
        }
    }
}
