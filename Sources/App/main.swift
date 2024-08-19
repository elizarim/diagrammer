import AppKit
import CirclePacking
import Foundation

//let fileManager = FileManager.shared

// #FF0000: red = 255, green = 0, blue = 0
//let color = NSColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)

extension NSColor {
    static func fromHEX(_ hex: String) -> NSColor? {
        var colorHex = hex
        if colorHex.hasPrefix("#") {
            colorHex.removeFirst()
        }

        guard colorHex.count == 6 else {
            return nil
        }

        let redHex = String(colorHex[colorHex.startIndex..<colorHex.index(colorHex.startIndex, offsetBy: 2)])
        let greenHex = String(colorHex[colorHex.index(colorHex.startIndex, offsetBy: 2)..<colorHex.index(colorHex.startIndex, offsetBy: 4)])
        let blueHex = String(colorHex[colorHex.index(colorHex.startIndex, offsetBy: 4)..<colorHex.index(colorHex.startIndex, offsetBy: 6)])

        guard let redInt = Int(redHex, radix: 16),
              let greenInt = Int(greenHex, radix: 16),
              let blueInt = Int(blueHex, radix: 16) else {
            return nil
        }

        let red = CGFloat(Int(redHex, radix: 16) ?? 0) / 255.0
        let green = CGFloat(Int(greenHex, radix: 16) ?? 0) / 255.0
        let blue = CGFloat(Int(blueHex, radix: 16) ?? 0) / 255.0

        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
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
        {"name": "AspectRatioBanker", "value": 2, "fill": "#FF000"}
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
        case fill
        case stroke
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let children = try container.decodeIfPresent([InputNode].self, forKey: .children)
        let value = try container.decodeIfPresent(Double.self, forKey: .value)
        let fillColor = try container.decodeIfPresent(String.self, forKey: .fill)
        let strokeColor = try container.decodeIfPresent(String.self, forKey: .stroke)

        let fill = fillColor.flatMap { NSColor.fromHEX($0) }
        let stroke = strokeColor.flatMap { NSColor.fromHEX($0) }

        switch (children, value) {
        case let (.none, .some(value)):
            self = .leaf(attributes: NodeAttributes(name: name, fill: fill, stroke: stroke), radius: value)
        case let (.some(children), .none):
            self = .branch(attributes: NodeAttributes(name: name, fill: fill, stroke: stroke), children: children)
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
