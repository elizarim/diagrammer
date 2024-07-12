import Foundation
@testable import CirclePacking

extension Distance {
    func rounded(floatingPoints: Int) -> Distance {
        let divisor = pow(10.0, Distance(floatingPoints))
        return (self * divisor).rounded() / divisor
    }
}

extension Point {
    func rounded(floatingPoints: Int) -> Point {
        Point(
            x: x.rounded(floatingPoints: floatingPoints),
            y: y.rounded(floatingPoints: floatingPoints)
        )
    }
}

extension Points {
    func rounded(floatingPoints: Int) -> Points {
        Points(
            first: first.map { $0.rounded(floatingPoints: floatingPoints) },
            second: second.map { $0.rounded(floatingPoints: floatingPoints) }
        )
    }
}
