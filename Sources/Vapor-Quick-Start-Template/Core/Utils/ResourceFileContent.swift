import Foundation
import Vapor

@propertyWrapper
struct ResourceFileContent {
    private let value: String
    private let fileName: String
    private let directory: Constants.Directory
    private let replaceList: [String: String]?
    
    init(
        fileName: String,
        directory: Constants.Directory = .resources,
        replaceList: [String: String]? = nil
    ) {
        self.fileName = fileName
        self.directory = directory
        self.replaceList = replaceList
        let filePath = directory.pathString + fileName
        do {
            value = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch {
            fatalError("\(fileName) couldnt load from \(directory) because: \(error.localizedDescription)")
        }
    }

    var wrappedValue: String { value }
}
