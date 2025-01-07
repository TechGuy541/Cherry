// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct DirectoryManager {
    public static let shared = DirectoryManager()
    
    fileprivate var directories: [String : [String : [String : MissingFile]]] {
        [
            "Cherry" : [ // PS2
                "memcards" : [:],
                "roms" : [:],
                "sysdata" : [
                    "bios.bin" : .init(
                        core: "Cherry",
                        extension: "bin",
                        importance: .required,
                        isSystemFile: true,
                        name: "bios.bin",
                        nameWithoutExtension: "bios")
                ]
            ]
            
        ]
    }
    
    public func createMissingDirectoriesInDocumentsDirectory(for cores: [String]) throws {
        let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        try directories.forEach {
            if cores.contains($0) {
                let coreDirectory = if #available(iOS 16, *) {
                    documentsDirectory.appending(component: $0)
                } else {
                    documentsDirectory.appendingPathComponent($0)
                }
                
                if !FileManager.default.fileExists(atPath: coreDirectory.path) {
                    try FileManager.default.createDirectory(at: coreDirectory, withIntermediateDirectories: false)
                    
                    try $1.forEach {
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0.key)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                } else {
                    try $1.forEach {
                        let coreSubdirectory = coreDirectory.appendingPathComponent($0.key)
                        if !FileManager.default.fileExists(atPath: coreSubdirectory.path) {
                            try FileManager.default.createDirectory(at: coreSubdirectory, withIntermediateDirectories: false)
                        }
                    }
                }
            }
        }
    }
    
    public func scanDirectoryForMissingFiles(for core: String) -> [MissingFile] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let directory = directories.first(where: { $0.key == core }) else {
            return []
        }
        
        var files: [MissingFile] = []
        
        directory.value.forEach { subdirectory, fileNames in
            let coreSubdirectory = documentsDirectory.appendingPathComponent(directory.key, conformingTo: .folder)
                .appendingPathComponent(subdirectory, conformingTo: .folder)
            fileNames.forEach { fileName, missingFile in
                if !FileManager.default.fileExists(atPath: coreSubdirectory.appendingPathComponent(fileName, conformingTo: .fileURL).path) {
                    files.append(missingFile)
                }
            }
        }
        
        return files
    }
}
