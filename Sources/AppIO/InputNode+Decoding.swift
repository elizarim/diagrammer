import AppKit
import CirclePacking

extension InputNode: Decodable {
    enum CodingKeys: String, CodingKey {
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
        let fillColor = try container.decodeColorIfPresent(forKey: .fill)
        let strokeColor = try container.decodeColorIfPresent(forKey: .stroke)

        switch (children, value) {
        case let (.none, .some(value)):
            self = .leaf(attributes: NodeAttributes(name: name, fill: fillColor, stroke: strokeColor), radius: value)
        case let (.some(children), .none):
            self = .branch(attributes: NodeAttributes(name: name, fill: fillColor, stroke: strokeColor), children: children)
        case (.none, .none):
            throw Self.error(codingPath: decoder.codingPath, described: "Node should contain children or value")
        case (.some, .some):
            throw Self.error(codingPath: decoder.codingPath, described: "Node should contain either children or value")
        }
    }

    private static func error(codingPath: [any CodingKey], described description: String) -> Error {
        DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: codingPath, debugDescription: description)
        )
    }
}

private extension KeyedDecodingContainer<InputNode.CodingKeys> {
    func decodeColorIfPresent(forKey key: Key) throws -> NSColor? {
        guard let hex = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        do {
            return try NSColor.fromHex(hex)
        } catch NSColor.DecodingError.noPrefix(let value) {
            throw error(described: "Color \(value) should start with #")
        } catch NSColor.DecodingError.invalidLength(let value, let expectedLength) {
            throw error(described: "Invalid length of color \(value) (expected length is \(expectedLength))")
        } catch NSColor.DecodingError.invalidNumber(let value) {
            throw error(described: "Unexpected characters in \(value) (expected characters in range 0...F)")
        } catch {
            throw error
        }
    }

    private func error(described description: String) -> DecodingError {
        return DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: description))
    }
}

private extension NSColor {
    enum DecodingError: Error {
        case noPrefix(value: String)
        case invalidLength(value: String, expectedLength: Int)
        case invalidNumber(value: String)
    }

    static func fromHex(_ hex: String) throws -> NSColor {
        guard hex.hasPrefix("#") else {
            throw DecodingError.noPrefix(value: hex)
        }
        guard hex.count == expectedHexLength else {
            throw DecodingError.invalidLength(value: hex, expectedLength: expectedHexLength)
        }
        do {
            return NSColor(
                red: try .colorComponent(fromHex: hex[1...2]),
                green: try .colorComponent(fromHex: hex[3...4]),
                blue: try .colorComponent(fromHex: hex[5...6]),
                alpha: 1.0
            )
        } catch {
            throw DecodingError.invalidNumber(value: hex)
        }
    }

    private static var expectedHexLength: Int { 7 }
}

private extension CGFloat {
    enum DecodingError: Error {
        case malformed
    }

    static func colorComponent(fromHex hex: String) throws -> CGFloat {
        guard let value = Int(hex, radix: 16) else {
            throw DecodingError.malformed
        }
        return CGFloat(value) / 255.0
    }
}

private extension String {
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let upperIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[lowerIndex...upperIndex])
    }
}
