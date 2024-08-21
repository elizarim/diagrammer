import ArgumentParser
import AppKit
import AppIO
import CirclePacking
import Foundation

func composeDiagramURL() -> URL {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    return documentsURL.appendingPathComponent("diagram.png")
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

do {
    let decoder = JSONDecoder()
    let tree = try decoder.decode(InputNode.self, from: json)
    let diagram = Diagram(
        rootCircle: tree.pack(padding: 2),
        canvasRect: NSRect(origin: .zero, size: NSSize(width: 640, height: 480))
    )
    let diagramURL = composeDiagramURL()
    let diagramImage = diagram.draw()
    try diagramImage.save(at: diagramURL)
    print("Diagram saved at \(diagramURL)")
} catch NSImage.ImageSavingError.serialization {
    print("Failed to convert image to data")
} catch NSImage.ImageSavingError.filesystem(let reason) {
    print("Failed to save image. \(reason)")
} catch {
    print("Error: \(error)")
}
