import AppKit
import CirclePacking

extension NSRect {
    var rawValue: Rect {
        Rect(
            origin: Point(x: origin.x, y: origin.y),
            size: Size(width: size.width, height: size.height)
        )
    }
}
