//
//  main.swift
//  CAStreamFormatTester
//
//  Created by 조수환 on 2023/05/06.
//

import Foundation
import AudioToolbox

autoreleasepool {
    var fileTypeAndFormat = AudioFileTypeAndFormatID(
        mFileType: kAudioFileCAFType,
        mFormatID: kAudioFormatMPEG4AAC
    )
    let specifierSize = UInt32(MemoryLayout.size(ofValue: fileTypeAndFormat))

    var audioErr = noErr
    var infoSize: UInt32 = 0

    audioErr = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                          specifierSize,
                                          &fileTypeAndFormat,
                                          &infoSize)

    if audioErr != noErr {
        let format4cc = withUnsafePointer(to: audioErr.bigEndian) {
            String(format: "%4.4s", arguments: [$0])
        }

        print("audioErr = \(format4cc)")

        assert(false)
    }

    let asbdCount = Int(infoSize) / MemoryLayout<AudioStreamBasicDescription>.size

    let asbds: [AudioStreamBasicDescription] = .init(unsafeUninitializedCapacity: asbdCount) { (buffer, count) in
        
        audioErr = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
                                          specifierSize,
                                          &fileTypeAndFormat,
                                          &infoSize,
                                          buffer.baseAddress!)
        assert(audioErr == noErr)

        count = Int(infoSize) / MemoryLayout<AudioStreamBasicDescription>.size
    }

    for (i, asbd) in asbds.enumerated() {
        let format4cc = withUnsafePointer(to: asbd.mFormatID.bigEndian) {
            String(format: "%4.4s", arguments: [$0])
        }

        print("\(i): mFormatID: \(format4cc), mFormatFlags: \(asbd.mFormatFlags), mBitsPerChannel: \(asbd.mBitsPerChannel)")
    }
}

