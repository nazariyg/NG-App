// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public enum MimeType: String, CaseIterable {

    // For every case of mime types, the raw string value is the corresponding file extension for that mime type.

    case ai
    case asf
    case asx
    case atom
    case avi
    case bin
    case bmp
    case cco
    case crt
    case css
    case deb
    case der
    case dll
    case dmg
    case doc
    case docx
    case ear
    case eot
    case eps
    case exe
    case flv
    case gif
    case hqx
    case htc
    case html
    case ico
    case img
    case iso
    case jad
    case jar
    case jardiff
    case jng
    case jnlp
    case jpeg
    case js
    case json
    case kar
    case kml
    case kmz
    case m3u8
    case m4a
    case m4v
    case midi
    case mml
    case mng
    case mov
    case mp3
    case mp4
    case mpeg
    case msi
    case msm
    case msp
    case ogg
    case pdb
    case pdf
    case pem
    case pl
    case pm
    case png
    case ppt
    case pptx
    case prc
    case protobuf
    case ps
    case ra
    case rar
    case rpm
    case rss
    case rtf
    case run
    case sea
    case sevenZip = "7z"
    case shtml
    case sit
    case svg
    case svgz
    case swf
    case tcl
    case threeGP = "3gp"
    case threeGPP = "3gpp"
    case tiff
    case tk
    case ts
    case txt
    case war
    case wbmp
    case webm
    case webp
    case wml
    case wmlc
    case wmv
    case woff
    case xhtml
    case xls
    case xlsx
    case xml
    case xpi
    case xspf
    case zip

    // MARK: - Lifecycle

    /// Constructs a mime type from a file extension. Case-instensitive.
    public init?(fileExtension: String) {
        let fileExtensionLowercased = fileExtension.lowercased()
        let foundCase = Self.allCases.first { $0.rawValue.lowercased() == fileExtensionLowercased }
        if let foundCase = foundCase {
            self = foundCase
        } else {
            return nil
        }
    }

    /// Constructs a mime type from a mime type string. Case-instensitive.
    public init?(mimeTypeString: String) {
        if let defaultMimeType = Self.defaultMimeType(forString: mimeTypeString) {
            self = defaultMimeType
            return
        }
        let mimeTypeStringLowercased = mimeTypeString.lowercased()
        let foundCase = Self.caseToMimeTypeString.anyKey(forValue: mimeTypeStringLowercased)
        if let foundCase = foundCase {
            self = foundCase
        } else {
            return nil
        }
    }

    // MARK: - Representations

    /// Returns the corresponding mime type string.
    public var string: String {
        if let mimeTypeString = Self.caseToMimeTypeString[self] {
            return mimeTypeString
        } else {
            assertionFailure()
            return ""
        }
    }

    /// Returns the corresponding file extension.
    public var fileExtension: String {
        return rawValue
    }

    // MARK: - Private

    // Mime type strings must be in lowercase.
    private static let caseToMimeTypeString: [Self: String] = [
        .ai: "application/postscript",
        .asf: "video/x-ms-asf",
        .asx: "video/x-ms-asf",
        .atom: "application/atom+xml",
        .avi: "video/x-msvideo",
        .bin: "application/octet-stream",
        .bmp: "image/x-ms-bmp",
        .cco: "application/x-cocoa",
        .crt: "application/x-x509-ca-cert",
        .css: "text/css",
        .deb: "application/octet-stream",
        .der: "application/x-x509-ca-cert",
        .dll: "application/octet-stream",
        .dmg: "application/octet-stream",
        .doc: "application/msword",
        .docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        .ear: "application/java-archive",
        .eot: "application/vnd.ms-fontobject",
        .eps: "application/postscript",
        .exe: "application/octet-stream",
        .flv: "video/x-flv",
        .gif: "image/gif",
        .hqx: "application/mac-binhex40",
        .htc: "text/x-component",
        .html: "text/html",
        .ico: "image/x-icon",
        .img: "application/octet-stream",
        .iso: "application/octet-stream",
        .jad: "text/vnd.sun.j2me.app-descriptor",
        .jar: "application/java-archive",
        .jardiff: "application/x-java-archive-diff",
        .jng: "image/x-jng",
        .jnlp: "application/x-java-jnlp-file",
        .jpeg: "image/jpeg",
        .js: "application/javascript",
        .json: "application/json",
        .kar: "audio/midi",
        .kml: "application/vnd.google-earth.kml+xml",
        .kmz: "application/vnd.google-earth.kmz",
        .m3u8: "application/vnd.apple.mpegurl",
        .m4a: "audio/x-m4a",
        .m4v: "video/x-m4v",
        .midi: "audio/midi",
        .mml: "text/mathml",
        .mng: "video/x-mng",
        .mov: "video/quicktime",
        .mp3: "audio/mpeg",
        .mp4: "video/mp4",
        .mpeg: "video/mpeg",
        .msi: "application/octet-stream",
        .msm: "application/octet-stream",
        .msp: "application/octet-stream",
        .ogg: "audio/ogg",
        .pdb: "application/x-pilot",
        .pdf: "application/pdf",
        .pem: "application/x-x509-ca-cert",
        .pl: "application/x-perl",
        .pm: "application/x-perl",
        .png: "image/png",
        .ppt: "application/vnd.ms-powerpoint",
        .pptx: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        .prc: "application/x-pilot",
        .protobuf: "application/protobuf",
        .ps: "application/postscript",
        .ra: "audio/x-realaudio",
        .rar: "application/x-rar-compressed",
        .rpm: "application/x-redhat-package-manager",
        .rss: "application/rss+xml",
        .rtf: "application/rtf",
        .run: "application/x-makeself",
        .sea: "application/x-sea",
        .sevenZip: "application/x-7z-compressed",
        .shtml: "text/html",
        .sit: "application/x-stuffit",
        .svg: "image/svg+xml",
        .svgz: "image/svg+xml",
        .swf: "application/x-shockwave-flash",
        .tcl: "application/x-tcl",
        .threeGP: "video/3gpp",
        .threeGPP: "video/3gpp",
        .tiff: "image/tiff",
        .tk: "application/x-tcl",
        .ts: "video/mp2t",
        .txt: "text/plain",
        .war: "application/java-archive",
        .wbmp: "image/vnd.wap.wbmp",
        .webm: "video/webm",
        .webp: "image/webp",
        .wml: "text/vnd.wap.wml",
        .wmlc: "application/vnd.wap.wmlc",
        .wmv: "video/x-ms-wmv",
        .woff: "application/font-woff",
        .xhtml: "application/xhtml+xml",
        .xls: "application/vnd.ms-excel",
        .xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        .xml: "text/xml",
        .xpi: "application/x-xpinstall",
        .xspf: "application/xspf+xml",
        .zip: "application/zip"
    ]

    private static func defaultMimeType(forString mimeTypeString: String) -> Self? {
        let mimeTypeStringLowercased = mimeTypeString.lowercased()
        if Self.bin.rawValue.lowercased() == mimeTypeStringLowercased { return Self.bin }  // "application/octet-stream" -> .bin
        return nil
    }

}
