public typealias FloatType = Double

extension FloatType {
  static let epsilon = FloatType(Float.ulpOfOne)
}

enum InputNode: ExpressibleByFloatLiteral, ExpressibleByArrayLiteral {
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

    init(floatLiteral value: FloatType) {
        self = .leaf(radius: value)
    }

    init(arrayLiteral elements: InputNode...) {
        self = .branch(children: elements)
    }

    func pack() -> CircleNode {
        fatalError()
//        switch self {
//        case let .leaf(radius):
//            return CircleNode(state: .leaf, radius: radius)
//        case let .branch(children):
//            let packedChildren = children.map { $0.pack() }
//            let packedRadius = packedChildren.reduce(0) { $0 + $1.radius }
//            return CircleNode(state: .branch(children: packedChildren), radius: packedRadius)
//        }
    }
}

public extension Array where Element == FlatCircle {
    mutating func orderSpatially(padding: Distance) {
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
