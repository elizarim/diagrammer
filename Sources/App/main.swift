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

let canvasRect = NSRect(origin: .zero, size: NSSize(width: 640, height: 480))
let tree = try decoder.decode(InputNode.self, from: json)
var packedTree = tree.pack(padding: 2)
let diagram = Diagram(rootCircle: packedTree, canvasRect: canvasRect)

func drawDiagram() {
    let diagramURL = composeDiagramURL()
    let diagram = diagram.draw()
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}

drawDiagram()
