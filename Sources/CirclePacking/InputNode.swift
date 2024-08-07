public typealias FloatType = Double

extension FloatType {
  static let epsilon = FloatType(Float.ulpOfOne)
}

public enum InputNode: ExpressibleByFloatLiteral, ExpressibleByArrayLiteral {
    case branch(children: [InputNode])
    case leaf(radius: FloatType)

    var count: Int {
        switch self {
        case let .branch(children):
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
        case let .leaf(radius):
            let flatCircle = FlatCircle(radius: radius, center : .zero)
            return CircleNode(state: .leaf, geometry: flatCircle)
        case let .branch(children):
            var packedChildren = children.map { $0.pack() }
            packedChildren.orderSpatially(padding: 8)
            var outerCircle: OuterCircle

            switch packedChildren.count {
            case 0:
                outerCircle = OuterCircle(for: nil, nil, padding: 8)
            case 1:
                outerCircle = OuterCircle(for: packedChildren[0], nil, padding: 8)
            case 2:
                outerCircle = OuterCircle(for: packedChildren[0], packedChildren[1], padding: 8)
            default:
                outerCircle = OuterCircle(for: packedChildren[0], packedChildren[1], padding: 8)
                outerCircle = outerCircle.union(packedChildren, padding: 8)
            }
            
            for index in packedChildren.indices {
                packedChildren[index].center -= outerCircle.center
            }
            return CircleNode(
                state: .branch(children: packedChildren),
                geometry: FlatCircle(
                    radius: outerCircle.radius,
                    center: .zero
                )
            )
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
