import ArgumentParser
import AppKit
import AppIO
import CirclePacking
import Foundation

struct InputArguments: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to the input JSON file")
    var input: String

    @Option(name: .shortAndLong, help: "Path to save the output diagram")
    var output: String

    @Option(name: .shortAndLong, help: "Width of the canvas")
    var width: Int = 1640

    @Option(name: .shortAndLong, help: "Height of the canvas")
    var height: Int = 1480

    @Option(name: .shortAndLong, help: "The background color in hex format")
    var background: String = "#0000FF"

    @Option(name: .shortAndLong, help: "The fill color in hex format")
    var fill: String = "#FF0000"

    @Option(name: .shortAndLong, help: "The stroke color in hex format")
    var stroke: String = "#00FF00"

    func composeDiagramURL() -> URL {
        return URL(fileURLWithPath: output)
    }

    func loadJsonFromFile() throws -> Data {
        let fileURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "FileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found at path: \(fileURL.path)"])
        }
        return try Data(contentsOf: fileURL)
    }

    func run() throws {
        do {
            let backgroundColor = try NSColor.fromHex(background)
            let fillColor = try NSColor.fromHex(fill)
            let strokeColor = try NSColor.fromHex(stroke)
            let jsonData = try loadJsonFromFile()
            let decoder = JSONDecoder()
            let tree = try decoder.decode(InputNode.self, from: jsonData)
            let diagramURL = composeDiagramURL()
            let canvasSize = NSSize(width: width, height: height)
            let packedTree = tree.pack(padding: 2, packFill: fillColor, packStroke: strokeColor)
            let diagram = Diagram(
                rootCircle: packedTree,
                canvasRect: NSRect(origin: .zero, size: canvasSize),
                backgroundColor: backgroundColor
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
