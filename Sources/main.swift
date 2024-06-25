enum Tree: ExpressibleByIntegerLiteral {
    case empty
    indirect case subtree(branches: [Tree], payload: Int)

    init(payload: Int) {
        self = .subtree(branches: [], payload: payload)
    }

    init(integerLiteral value: Int) {
        self = .subtree(branches: [], payload: value)
    }
}

let tree: Tree = .subtree(
    branches: [
        .subtree(
            branches: [
                .subtree(branches: [7], payload: 5),
                .subtree(branches: [3], payload: 4),
            ],
            payload: 6
        ),
        9
    ],
    payload: 1
)

func summarize(tree: Tree) -> Int {
    switch tree {
        case .empty:
            return 0
        case .subtree(let branches, let payload):
            var result = payload
            for branche in branches {
                result += summarize(tree: branche)
            }
            return result
    }
}

print(summarize(tree: tree))

