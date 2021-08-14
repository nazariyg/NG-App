// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension FileManager {

    // MARK: - Common directory URLs

    static var documentsURL: URL {
        let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dirURL
    }

    static var cachesURL: URL {
        let dirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dirURL
    }

    // MARK: - Files

    func fileSize(ofFileAtURL fileURL: URL) -> FileSize? {
        guard let attributesDict = try? attributesOfItem(atPath: fileURL.path) as NSDictionary else { return nil }
        return FileSize(bytes: attributesDict.fileSize())
    }

    static func generateTemporaryDocumentsFileURL() -> URL {
        let fileName = UUID().uuidString
        let directoryURL = temporaryDirectoryURL()
        let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
        return fileURL
    }

    static func generateTemporaryDocumentsFileURL(forMimeType mimeType: MimeType) -> URL {
        let fileName = "\(UUID().uuidString).\(mimeType.fileExtension)"
        let directoryURL = temporaryDirectoryURL()
        let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
        return fileURL
    }

    private static func temporaryDirectoryURL() -> URL {
        let directoryURL = documentsURL.appendingPathComponent("tmp", isDirectory: true)
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        return directoryURL
    }

}
