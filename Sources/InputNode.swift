typealias FloatType = Double

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
        switch self {
        case let .leaf(radius):
            return CircleNode(state: .leaf, radius: radius)
        case let .branch(children):
            let packedChildren = children.map { $0.pack() }
            let packedRadius = packedChildren.reduce(0) { $0 + $1.radius }
            return CircleNode(state: .branch(children: packedChildren), radius: packedRadius)
        }
    }
}
