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

extension FlatCircle {
    var bezierPath: NSBezierPath {
        NSBezierPath(ovalIn: NSRect(
            origin: NSPoint(x: center.x - radius, y: center.y - radius),
            size: NSSize(width: radius * 2, height: radius * 2)
        ))
    }
}

func drawDiagram(drawingHandler: @escaping (NSRect) -> Bool) {
    let diagramURL = composeDiagramURL()
    let diagramSize = NSSize(width: 100, height: 100)
    let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawingHandler)
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}


let a = FlatCircle(radius: 20, center: Point(x: 30, y: 30))
var b = FlatCircle(radius: 20, center: .zero)
b.put(nextTo: a)
var c = FlatCircle(radius: 20, center: .zero)
c.put(between: a, b)

func orderCircles(_ circles: [FlatCircle]) -> [FlatCircle] {
    // 1. Сортирует массив circles по возрастанию радиуса
    // 2. Располагает вторую окружность рядом с первой
    // 3. Цикл по всем окружностям
    //    3.1 Пробуем расположить current-окружность между окружностями pivot и head
    //    3.2 Смотрим, есть ли окружности между pivot + 1 и head - 1, с которой пересекается current
    //        (для этого используем метод firstCollisionIndex)
    //    3.2.1 Если такая окружность найдена, то назначаем её в качестве pivot и повторяем процедуру с шага 3.1
    //    3.2.2 Если такая окружность не найдена, то назначаем её в качестве head и переходим к расположению следующей окружности.
    return circles
}

drawDiagram { rect in
    NSColor.black.set()
    rect.fill()
    NSColor.yellow.set()
    orderCircles([a, b, c]).forEach { $0.bezierPath.fill() }
    return true
}
