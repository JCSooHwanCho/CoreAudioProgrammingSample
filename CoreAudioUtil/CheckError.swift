//
//  CheckError.swift
//  CoreAudioUtil
//
//  Created by 조수환 on 2023/05/07.
//

import Foundation

public func checkError(_ error: OSStatus) {
    guard error != noErr else { return }

    let chars = withUnsafeBytes(of: error.bigEndian) { Array($0) }

    let errorString: String
    if chars.allSatisfy({ isprint(Int32($0)) != 0 }) {
        errorString = "'\(String(cString: chars + [0]))'"
    } else {
        errorString = "\(error)"
    }

    try! FileHandle.standardError.write(contentsOf: Data(errorString.utf8))
    exit(1)
}
