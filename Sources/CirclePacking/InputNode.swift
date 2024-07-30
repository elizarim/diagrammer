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
            let flatCircle = FlatCircle(radius: radius, center: Point(x: 200, y: 200))
            return CircleNode(state: .leaf, geometry: flatCircle)

        case let .branch(children):
            var packedChildren = children.map { $0.pack() }
            var childCircles = packedChildren.map { $0.geometry }
            childCircles.orderSpatially(padding: 4)
            var outerCircle = OuterCircle(for: childCircles[0], childCircles[1])
            outerCircle = outerCircle.union(childCircles)
            for index in packedChildren.indices {
                updateChildrenCenters(node: &packedChildren[index], newCenter: childCircles[index].center)
            }
            for index in packedChildren.indices {
                packedChildren[index].geometry = childCircles[index]
            }
            return CircleNode(state: .branch(children: packedChildren), geometry: FlatCircle(radius: outerCircle.union(childCircles).radius, center: outerCircle.union(childCircles).center))
        }
    }

    func updateChildrenCenters(node: inout CircleNode, newCenter: Point) {
        switch node.state {
        case .leaf:
            node.geometry.center = newCenter
        case .branch(var children):
            let offset = newCenter - node.geometry.center
            node.geometry.center = newCenter
            for index in children.indices {
                var child = children[index]
                let newChildCenter = child.geometry.center + offset
                updateChildrenCenters(node: &child, newCenter: newChildCenter)
                children[index] = child
            }
            node.state = .branch(children: children)
        }
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
