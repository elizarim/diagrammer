import AppKit

public typealias FloatType = Double

extension FloatType {
    static let epsilon = FloatType(Float.ulpOfOne)
}

public struct NodeAttributes {
    public var name: String?
    public var fill: NSColor?
    public var stroke: NSColor?

    public init(name: String? = nil, fill: NSColor? = nil, stroke: NSColor? = nil) {
        self.name = name
        self.fill = fill ?? .clear
        self.stroke = stroke ?? .yellow
    }
}

public enum InputNode: ExpressibleByFloatLiteral, ExpressibleByArrayLiteral {
    case branch(attributes: NodeAttributes, children: [InputNode])
    case leaf(attributes: NodeAttributes, radius: FloatType)

    public var count: Int {
        switch self {
        case let .branch(_, children):
            return children.reduce(1) { $0 + $1.count }
        case .leaf:
            return 1
        }
    }

    public init(floatLiteral value: FloatType) {
        self = .leaf(attributes: NodeAttributes(), radius: value)
    }

    public init(arrayLiteral elements: InputNode...) {
        self = .branch(attributes: NodeAttributes(), children: elements)
    }

    public func pack(padding: Distance, packFill: NSColor?, packStroke: NSColor?) -> CircleNode {
        switch self {
        case let .leaf(attributes, radius):
            let updatedAttributes = NodeAttributes(
                name: attributes.name,
                fill: packFill,
                stroke: packStroke
            )
            let flatCircle = FlatCircle(radius: radius, center : .zero)
            return CircleNode(attributes: updatedAttributes, state: .leaf, geometry: flatCircle)
        case let .branch(attributes, children):
            let updatedAttributes = NodeAttributes(
                name: attributes.name,
                fill: packFill,
                stroke: packStroke
            )
            var packedChildren = children.map { $0.pack(padding: padding, packFill: packFill, packStroke: packStroke) }
            packedChildren.orderSpatially(padding: padding)
            return group(&packedChildren, updatedAttributes, padding)
        }
    }

    private func group(
        _ circles: inout [CircleNode],
        _ attributes: NodeAttributes,
        _ padding: Distance
    ) -> CircleNode {
        switch circles.count {
        case 0:
            return CircleNode(
                attributes: attributes,
                state: .branch(children: circles),
                geometry: FlatCircle(radius: padding, center: .zero)
            )
        case 1:
            return CircleNode(
                attributes: attributes,
                state: .branch(children: circles),
                geometry: FlatCircle(radius: circles[0].radius + padding, center: .zero)
            )
        default:
            let outerCircle = OuterCircle(for: circles[0], circles[1]).union(circles)
            for index in circles.indices {
                circles[index].center -= outerCircle.center
            }
            return CircleNode(
                attributes: attributes,
                state: .branch(children: circles),
                geometry: FlatCircle(
                    radius: outerCircle.radius + padding,
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


