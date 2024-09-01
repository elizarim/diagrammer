import AppKit
import CirclePacking

extension CircleNode {
    func draw(translation: Point = .zero, scaledBy scaleFactor: FloatType, fontColor: NSColor) {
        NSGraphicsContext.with(translation: translation) {
            attributes.fill?.set()
            bezierPath(scaledBy: scaleFactor).fill()
            attributes.stroke?.set()
            let strokePath = bezierPath(scaledBy: scaleFactor)
            strokePath.lineWidth = 2
            strokePath.stroke()
            switch state {
            case .leaf:
                drawName(scaledBy: scaleFactor, color: fontColor)
            case let .branch(children):
                for child in children {
                    child.draw(translation: center*scaleFactor, scaledBy: scaleFactor, fontColor: fontColor)
                }
            }
        }
    }

    private func drawName(scaledBy scaleFactor: FloatType, color: NSColor) {
        guard let text = attributes.name else {
            return
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: attributes.textColor ?? color,
            .font: NSFont.systemFont(ofSize: 24)
        ]
        let textRect = rect(for: text, with: attributes, scaledBy: scaleFactor)
        (text as NSString).draw(in: textRect, withAttributes: attributes)
    }
}

private extension Circle {
    func rect(for text: String, with attributes: [NSAttributedString.Key: Any], scaledBy scaleFactor: FloatType) -> NSRect {
        let textSize = (text as NSString).size(withAttributes: attributes)
        let nodeRect = nodeRect(scaledBy: scaleFactor)
        let x = nodeRect.origin.x + (nodeRect.width - textSize.width) / 2
        let y = nodeRect.origin.y + (nodeRect.height - textSize.height) / 2
        let textRect = NSRect(x: x, y: y, width: textSize.width, height: textSize.height)
        return textRect
    }

    func nodeRect(scaledBy scaleFactor: FloatType) -> NSRect {
        NSRect(
            origin: NSPoint(x: (center.x - radius)*scaleFactor, y: (center.y - radius)*scaleFactor),
            size: NSSize(width: radius * 2 * scaleFactor, height: radius * 2 * scaleFactor)
        )
    }

    func bezierPath(scaledBy scaleFactor: FloatType) -> NSBezierPath {
        NSBezierPath(ovalIn: nodeRect(scaledBy: scaleFactor))
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
