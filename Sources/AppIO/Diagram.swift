import AppKit
import CirclePacking

public struct Diagram {
    public var canvasRect: NSRect
    public var backgroundColor: NSColor
    public var rootCircle: CircleNode

    private var scaleFactor: FloatType {
        let expectedRadius = min(canvasRect.size.width, canvasRect.size.height) * 0.9
        let actualRadius = rootCircle.radius * 2
        let result = expectedRadius / actualRadius
        return result
    }

    public init(rootCircle: CircleNode, canvasRect: NSRect, backgroundColor: NSColor? = nil) {
        self.rootCircle = rootCircle
        self.canvasRect = canvasRect
        self.backgroundColor = backgroundColor ?? .black
    }

    public func draw() -> NSImage {
        NSImage(size: canvasRect.size, flipped: false) { _ in
            backgroundColor.set()
            canvasRect.fill()
            rootCircle.draw(translation: canvasRect.rawValue.center, scaledBy: scaleFactor)
            return true
        }
    }
}
