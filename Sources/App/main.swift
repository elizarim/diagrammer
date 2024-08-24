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

func loadJsonFromFile() throws -> Data {
    let fileURL = URL(fileURLWithPath: "/Users/liza/Downloads/flare-2.json")
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        throw NSError(domain: "FileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found at path: \(fileURL.path)"])
    }
    return try Data(contentsOf: fileURL)
}

struct InputArguments: ParsableCommand {
    @Option(name: .shortAndLong, help: "Width of the canvas")
    var width: Int = 1640

    @Option(name: .shortAndLong, help: "Height of the canvas")
    var height: Int = 1480

    func run() throws {
        do {
            let jsonData = try loadJsonFromFile()
            let decoder = JSONDecoder()
            let tree = try decoder.decode(InputNode.self, from: jsonData)
            let diagramURL = composeDiagramURL()
            let canvasSize = NSSize(width: width, height: height)
            let diagram = Diagram(
                rootCircle: tree.pack(padding: 2),
                canvasRect: NSRect(origin: .zero, size: canvasSize)
            )
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
    }
}

InputArguments.main()
