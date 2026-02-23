#!/usr/bin/env swift

import Foundation

let xcstringsPath = "Localizable.xcstrings"
let outputPath = "Generated/Strings+LocalizedExtension.swift"
let language = "en"

struct XCStringFile: Decodable {
    struct StringEntry: Decodable {
        let localizations: [String: LocalizationValue]?
    }

    struct LocalizationValue: Decodable {
        let value: String?
    }

    let strings: [String: StringEntry]
}

func loadXCStrings(from path: String) throws -> XCStringFile {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(XCStringFile.self, from: data)
}

do {
    let xcstrings = try loadXCStrings(from: xcstringsPath)
    let keys = xcstrings.strings.keys.sorted()

    var lines: [String] = []
    lines.append("// 🚀 Auto-generated file. Do not edit manually. Run this from command line:\n// swift Scripts/GenerateTextClass.swift\n\n")
    lines.append("import Foundation\n")
    lines.append("extension String {\n")

    for key in keys {
        let value = xcstrings.strings[key]?.localizations?[language]?.value ?? key
        lines.append("    static var \(sanitizeKey(key)) : String { NSLocalizedString(\"\(key)\", comment: \"\(value)\") }")
    }

    lines.append("}")

    let output = lines.joined(separator: "\n")
    try FileManager.default.createDirectory(atPath: (outputPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
    try output.write(toFile: outputPath, atomically: true, encoding: .utf8)

    print("✅ \(outputPath) generated successfully at \(outputPath)")
} catch {
    print("❌ Error:", error)
}

func sanitizeKey(_ key: String) -> String {
    let components = key.components(separatedBy: CharacterSet.alphanumerics.inverted)
    var safe = components.joined()
    if safe.first?.isNumber == true {
        safe = "_" + safe
    }
    return safe
}
