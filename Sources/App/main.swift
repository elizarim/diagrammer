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
    let diagramSize = NSSize(width: 300, height: 300)
    let diagram = NSImage(size: diagramSize, flipped: false, drawingHandler: drawingHandler)
    do {
        try saveImage(diagram, at: diagramURL)
        print("Diagram saved at \(diagramURL)")
    } catch {
        print(error)
    }
}

var a = FlatCircle(radius: 20, center: .zero)
var b = FlatCircle(radius: 20, center: .zero)
var c = FlatCircle(radius: 20, center: .zero)
var d = FlatCircle(radius: 25, center: .zero)
var e = FlatCircle(radius: 10, center: Point(x: 125, y: 175))
var f = FlatCircle(radius: 20, center: .zero)
var g = FlatCircle(radius: 30, center: .zero)
var h = FlatCircle(radius: 35, center: .zero)
var i = FlatCircle(radius: 20, center: .zero)
var j = FlatCircle(radius: 40, center: .zero)

private extension Array where Element == FlatCircle {
  mutating func orderSpatially(padding: Distance) {
    guard count > 1 else {
      return
    }
    sort { $0.radius < $1.radius }
    self[1].put(nextTo: self[0], padding: padding)
    var pivot = 0, current = 2
    while current < count {
      let head = current - 1
      assert(pivot != head)
      var circle = self[current]
      circle.put(between: self[head], self[pivot], padding: padding)
      if let collision =
          circle.firstCollisionIndex(in: self, between: pivot + 1, head - 1, padding: padding) {
        pivot = collision
        continue
      }
      self[current] = circle
      current += 1
    }
  }
}

func orderCircles(_ circles: [FlatCircle], padding: Distance) -> [FlatCircle] {
    guard circles.count > 1 else {
        return circles
    }
    var sortedCircles = circles.sorted { $0.radius < $1.radius }
    var orderedCircles: [FlatCircle] = []
    orderedCircles.append(sortedCircles[0])
    sortedCircles[1].put(nextTo: sortedCircles[0], padding: padding)
    orderedCircles.append(sortedCircles[1])
    var pivot = 0
    var head = 1
    for i in 2..<sortedCircles.count {
        var currentCircle = sortedCircles[i]
        repeat {
            currentCircle.put(between: orderedCircles[pivot], orderedCircles[head], padding: padding)
            if let collisionCircle = currentCircle.firstCollisionIndex(in: orderedCircles, between: pivot + 1, head - 1, padding: padding) {
                pivot = collisionCircle
            } else {
                head += 1
                orderedCircles.append(currentCircle)
                break
            }
        } while true
    }
    return orderedCircles
}

drawDiagram { rect in
    NSColor.black.set()
    rect.fill()
    NSColor.yellow.set()
    orderCircles([a, b, c, d, e, f, g, h, i, j], padding: 8).forEach { $0.bezierPath.fill() }
//    var circles = [a, b, c, d, e, f, g, h, i, j]
//    circles.orderSpatially(padding: 25)
//    circles.forEach { $0.bezierPath.fill() }
    return true
}
