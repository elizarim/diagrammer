// struct Leaf {
//     var radius: Int
// }


// struct Branch {
//     var branches: [Branch] = []
//     var leaves: [Leaf] = []
//     var radius: Int {
//         var resultRadius = 0
//         for leaf in leaves {
//             resultRadius += leaf.radius
//         }
//         for branch in branches {
//             resultRadius += branch.radius
//         }
//         return resultRadius
//     }
// }

typealias FloatType = Double

enum CircleItem: ExpressibleByFloatLiteral, ExpressibleByArrayLiteral {
    case branch(children: [CircleItem])
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

    init(arrayLiteral elements: CircleItem...) {
        self = .branch(children: elements)
    }
}

struct CircleNode {
    enum State {
        case leaf
        case branch(children: [CircleNode])
    }

    var state: State
    var radius: FloatType
}

func pack(item: CircleItem) -> CircleNode {
    switch item {
    case let .leaf(radius):
        return CircleNode(state: .leaf, radius: radius)
    case let .branch(children):
        fatalError()
    }
}

let treeItem: CircleItem = [9.0, 10.0, 11.0, [10.0, 12.0, [13.0]]]

//
// Expected result of the pack function:
//
// let treeNode = CircleNode(
//     state: .branch(children: [
//         CircleNode(state: .leaf, radius: 9.0),
//         CircleNode(state: .leaf, radius: 10.0),
//         CircleNode(state: .leaf, radius: 11.0),
//         CircleNode(
//             state: .branch(children: [
//                 CircleNode(state: .leaf, radius: 10.0),
//                 CircleNode(state: .leaf, radius: 12.0),
//                 CircleNode(
//                     state: .branch(children: [
//                         CircleNode(state: .leaf, radius: 13.0),
//                     ]),
//                     radius: 13.0
//                 )
//             ]),
//             radius: 35.0
//         ),
//     ]),
//     radius: 65.0
// )
//
let treeNode = pack(item: treeItem)

print(treeNode.radius)
