enum Tree: ExpressibleByIntegerLiteral {
  case empty
  indirect case subtree(left: Tree = .empty, right: Tree = .empty, payload: Int)

  init(payload: Int) {
    self = .subtree(payload: payload)
  }

  init(integerLiteral value: Int) {
    self = .subtree(payload: value)
  }
}

let tree: Tree = .subtree(
  left: .subtree(
    left: .subtree(
      left: 7,
      payload: 5
    ),
    right: .subtree(
      right: 3,
      payload: 4
    ),
    payload: 6
  ),
  right: 9,
  payload: 1
)

func summarize(tree: Tree) -> Int {
  switch tree {
    case .empty:
      return 0
    case .subtree(let left, let right, let payload):
      var result = payload
      result += summarize(tree: left)
      result += summarize(tree: right)
      return result
  }
}

print(summarize(tree: tree))
