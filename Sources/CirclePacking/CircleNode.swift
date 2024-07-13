typealias CircleRadius = Distance

struct CircleNode {
    enum State {
        case leaf
        case branch(children: [CircleNode])
    }

    var state: State
    var radius: FloatType
}