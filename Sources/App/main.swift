import AppKit
import AppIO
import CirclePacking
import Foundation

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

let json = """
{
  "name": "analytics",
  "children":
  [
    {
      "name": "cluster",
      "children": [
        {"name": "AgglomerativeCluster", "value": 7},
        {"name": "CommunityStructure", "value": 7},
        {"name": "HierarchicalCluster", "value": 4},
        {"name": "MergeEdge", "value": 5}
      ]
    },
    {
      "name": "graph",
      "children": [
        {"name": "BetweennessCentrality", "value": 7},
        {"name": "LinkDistance", "value": 7},
        {"name": "MaxFlowMinCut", "value": 4},
        {"name": "ShortestPaths", "value": 5},
        {"name": "SpanningTree", "value": 8}
      ]
    },
    {
      "name": "optimization",
      "children": [
        {"name": "AspectRatioBanker", "value": 2, "fill": "#FF0000"}
      ]
    }
  ]
}
""".data(using: .utf8)!

let decoder = JSONDecoder()

do {
    let node = try decoder.decode(InputNode.self, from: json)
    print("Decoded nodes count:", node.count)
} catch {
    print("Failed to decode input json:", error)
    exit(65)
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

var backRect = Rect(origin: Point(x: 0, y: 0), size: Size(width: 640, height: 480))

func drawDiagram(drawingHandler: @escaping (NSRect) -> Bool) {
    let diagramURL = composeDiagramURL()
    let diagramSize = NSSize(width: backRect.size.width, height: backRect.size.height)
    let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawingHandler)
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}

let tree = try decoder.decode(InputNode.self, from: json)
var changedCircles = tree.adjustRadiuses(width: backRect.size.width, height: backRect.size.height)
var circle = changedCircles.pack()

func drawNode(_ node: CircleNode, parentCenter: Point = .zero) {
    let currentCenter = node.center + parentCenter
    let currentCircle = FlatCircle(radius: node.radius, center: currentCenter)

    node.attributes.fill?.set()
    currentCircle.bezierPath.fill()

    node.attributes.stroke?.set()
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
    NSColor.clear.set()
    rect.fill()
    drawNode(circle, parentCenter: backRect.center)
    return true
}
