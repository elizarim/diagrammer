import AppKit
import CirclePacking
import Foundation

let json = """
{
  "name": "analytics",
  "children":
  [
    {
      "name": "cluster",
      "children": [
        {"name": "AgglomerativeCluster", "value": 57684},
        {"name": "CommunityStructure", "value": 67384},
        {"name": "HierarchicalCluster", "value": 28467},
        {"name": "MergeEdge", "value": 13546}
      ]
    },
    {
      "name": "graph",
      "children": [
        {"name": "BetweennessCentrality", "value": 37564},
        {"name": "LinkDistance", "value": 47563},
        {"name": "MaxFlowMinCut", "value": 84635},
        {"name": "ShortestPaths", "value": 65743},
        {"name": "SpanningTree", "value": 78546}
      ]
    },
    {
      "name": "optimization",
      "children": [
        {"name": "AspectRatioBanker", "value": 67843}
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
}

extension InputNode: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name
        case children
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let children = try container.decodeIfPresent([InputNode].self, forKey: .children)
        let value = try container.decodeIfPresent(Double.self, forKey: .value)
        switch (children, value) {
        case let (.none, .some(value)):
            self = .leaf(name: name, radius: value)
        case let (.some(children), .none):
            self = .branch(name: name, children: children)
        case (.none, .none):
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Node should contain children or value"
                )
            )
        case (.some, .some):
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Node should contain either children or value"
                )
            )
        }
    }
}

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
    let diagramSize = NSSize(width: 1000, height: 1000)
    let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawingHandler)
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}

let tree = try decoder.decode(InputNode.self, from: json)
var changedCircles = tree.adjustRadiuses(width: 800, height: 800)
var circle = changedCircles.pack()

func drawNode(_ node: CircleNode, parentCenter: Point = .zero) {
    let currentCenter = node.center + parentCenter
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
    drawNode(circle, parentCenter: Rect(origin: Point(x: 100, y: 100), size: Size(width: 800, height: 800)).center)
    return true
}
