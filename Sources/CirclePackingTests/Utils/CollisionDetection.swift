import Foundation
@testable import CirclePacking

extension Array where Element == FlatCircle {
    func hasCollisions() -> Bool {
        for i in indices.dropLast() {
            for j in index(after: i)...index(before: indices.endIndex) {
                if self[i].collides(with: self[j]) {
                    return true
                }
            }
        }
        return false
    }
}
