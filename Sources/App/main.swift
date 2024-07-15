import AppKit

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
        let pngData = bitmap.representation(using: .png, properties: [:])
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

func drawDiagram(in rect: NSRect) -> Bool {
    NSColor.black.set()
    rect.fill()
    NSColor.yellow.set()
    NSBezierPath(ovalIn: NSRect(x: 25, y: 25, width: 50, height: 50)).fill()
    return true
}

let diagramURL = composeDiagramURL()
let diagramSize = NSSize(width: 100, height: 100)
let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawDiagram(in:))
do {
    try saveImage(diagram, at: diagramURL)
    print("Diagram saved at \(diagramURL)")
} catch {
    print(error)
}
