//
//  FileFunc.swift
//  OurAR
//
//  Created by lee on 2023/8/22.
//

import Foundation

func basePath() -> String {
    return NSHomeDirectory() + "/Documents/";
}
@discardableResult
func existOfFile(fileName: String,extension: FileExtention) -> Bool {
    return FileManager().fileExists(atPath: basePath() + "\(fileName).\(`extension`.rawValue)")
}
@discardableResult
func createFile(name: String,extension: FileExtention) -> Bool {
    if name.isEmpty {
        return false
    }
    if !existOfFile(fileName: name, extension: `extension`) {
        return FileManager().createFile(atPath: basePath() + "\(name).\(`extension`.rawValue)", contents: nil)
    }
    return false
}

func readFile(name: String,extension: FileExtention) ->String? {
    do {
        let readStr = try NSString(contentsOfFile: basePath() + "\(name).\(`extension`.rawValue)", encoding: String.Encoding.utf8.rawValue)
        return String(readStr)
    } catch {
        print(error)
    }
    return nil
}

func writeFile(name: String,extension: FileExtention,info: String) {
    if !existOfFile(fileName: name, extension: `extension`) {
        createFile(name: name, extension: `extension`)
    }
    do {
        try info.write(toFile: basePath() + "\(name).\(`extension`.rawValue)", atomically: false, encoding: String.Encoding.utf8)
    } catch {
        print(error)
    }
}
