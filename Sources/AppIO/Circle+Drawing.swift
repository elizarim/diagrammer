import AppKit
import CirclePacking

extension CircleNode {
    func draw(translation: Point = .zero, scaledBy scaleFactor: FloatType) {
        NSGraphicsContext.with(translation: translation) {
            attributes.fill?.set()
            bezierPath(scaledBy: scaleFactor).fill()
            attributes.stroke?.set()
            let strokePath = bezierPath(scaledBy: scaleFactor)
            strokePath.lineWidth = 2
            strokePath.stroke()
            switch state {
            case .leaf:
                break
            case let .branch(children):
                for child in children {
                    child.draw(translation: center*scaleFactor, scaledBy: scaleFactor)
                }
            }
        }
    }
}

private extension Circle {
    func bezierPath(scaledBy scaleFactor: FloatType) -> NSBezierPath {
        NSBezierPath(ovalIn: NSRect(
            origin: NSPoint(x: (center.x - radius)*scaleFactor, y: (center.y - radius)*scaleFactor),
            size: NSSize(width: radius * 2 * scaleFactor, height: radius * 2 * scaleFactor)
        ))
    }
}

extension NSGraphicsContext {
    static func with(translation point: Point, _ draw: () -> Void) {
        let context = current!.cgContext
        let transform = CGAffineTransform(translationX: point.x, y: point.y)
        context.concatenate(transform)
        draw()
        context.concatenate(transform.inverted())
    }
}
