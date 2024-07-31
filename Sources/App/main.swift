import AppKit
import CirclePacking

/// Possible errors in the app.
enum AppError: Error, CustomStringConvertible {
    case imageSerialization
    case imageSaving(Error)

    var description: String {
        switch self {
        case .imageSerialization: return "Failed to convert image to data"
        case let .imageSaving(reason): return "Failed to save image. \(reason)"
        }
    }
}

func saveImage(_ image: NSImage, at fileURL: URL) throws {
    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0])
    else {
        throw AppError.imageSerialization
    }
    do {
        try pngData.write(to: fileURL)
    } catch {
        throw AppError.imageSaving(error)
    }
}

func composeDiagramURL() -> URL {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsURL.appendingPathComponent("diagram.png")
}

extension FlatCircle {
    var bezierPath: NSBezierPath {
        NSBezierPath(ovalIn: NSRect(
            origin: NSPoint(x: center.x - radius, y: center.y - radius),
            size: NSSize(width: radius * 2, height: radius * 2)
        ))
    }
}

extension OuterCircle {
    var bezierPath: NSBezierPath {
        NSBezierPath(ovalIn: NSRect(
            origin: NSPoint(x: center.x - radius, y: center.y - radius),
            size: NSSize(width: radius * 2, height: radius * 2)
        ))
    }
}

func drawDiagram(drawingHandler: @escaping (NSRect) -> Bool) {
    let diagramURL = composeDiagramURL()
    let diagramSize = NSSize(width: 800, height: 800)
    let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawingHandler)
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}

//var a = FlatCircle(radius: 15, center: .zero)
//var b = FlatCircle(radius: 20, center: .zero)
//var c = FlatCircle(radius: 20, center: .zero)
//var d = FlatCircle(radius: 25, center: .zero)
//var e = FlatCircle(radius: 10, center: Point(x: 125, y: 125))
//var f = FlatCircle(radius: 20, center: .zero)
//var g = FlatCircle(radius: 30, center: .zero)
//var h = FlatCircle(radius: 35, center: .zero)
//var i = FlatCircle(radius: 20, center: .zero)
//var j = FlatCircle(radius: 40, center: .zero)

let tree: InputNode = [

    [
        [8.0, 9.0],
        [10.0, 12.0],
    ],
    [
        [1.0, 2.0],
        [1.0, 2.0],
    ],

]
var circle = tree.pack()

func drawNode(_ node: CircleNode, parentCenter: Point = .zero) {
    let currentCenter = Point(x: parentCenter.x + node.center.x, y: parentCenter.y + node.center.y)
    let currentCircle = FlatCircle(radius: node.radius, center: currentCenter)
    currentCircle.bezierPath.stroke()
    switch node.state {
    case .leaf:
        break
    case let .branch(children):
        for child in children {
            drawNode(child, parentCenter: currentCenter)
        }
    }
}

drawDiagram { rect in
    NSColor.black.set()
    rect.fill()
    NSColor.yellow.set()
//    var circles = [a, b, c, d, e, f, g, h, i, j]
//    circles.orderSpatially(padding: 8)
//    var outerCircle = OuterCircle(for: circles[3], circles[9])
//    circles.forEach { $0.bezierPath.stroke() }
//    let finalOuterCircle = outerCircle.union(circles)
//    finalOuterCircle.bezierPath.stroke()
    drawNode(circle)
    return true
}
