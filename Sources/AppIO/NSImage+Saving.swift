import AppKit

public extension NSImage {
    enum ImageSavingError: Error {
        case serialization
        case filesystem(Error)
    }

    func save(at fileURL: URL) throws {
        guard
            let tiffData = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0])
        else {
            throw ImageSavingError.serialization
        }
        do {
            try pngData.write(to: fileURL)
        } catch {
            throw ImageSavingError.filesystem(error)
        }
    }
}
