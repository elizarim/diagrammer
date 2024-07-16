import Foundation

public struct Points {
    var first: Point?
    var second: Point?

    static func + (a: Points, b: Point) -> Points {
        Points(first: a.first.map { $0 + b }, second: a.second.map { $0 + b })
    }
}
