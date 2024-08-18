public struct CircleNode {
    public enum State {
        case leaf
        case branch(children: [CircleNode])
    }

    public var attributes: NodeAttributes
    public var state: State
    public var geometry: FlatCircle
}
