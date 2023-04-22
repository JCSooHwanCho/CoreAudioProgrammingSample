//
//  main.swift
//  CoreAudioBook
//
//  Created by 조수환 on 2023/04/22.
//

import Foundation
import Darwin
import AudioToolbox

autoreleasepool {
    if CommandLine.argc < 2 {
        print("Usage: CAMetadata /full/path/to/audiofile")
        exit(-1)
    }

    let audioFilePath = (CommandLine.arguments[1] as NSString).expandingTildeInPath
    let url = URL(fileURLWithPath: audioFilePath)

    var audioFile: AudioFileID?
    var theErr = AudioFileOpenURL(url as CFURL,
                                  AudioFilePermissions.readPermission,
                                  0,
                                  &audioFile)
    guard theErr == noErr,
          let audioFile else {
        exit(-1)
    }

    var dictionarySize: Int32 = 0

    theErr = AudioFileGetPropertyInfo(audioFile,
                                      kAudioFilePropertyInfoDictionary,
                                      &dictionarySize,
                                      nil)

    guard theErr == noErr else { exit(-1) }

    var dictionary: NSDictionary?

    theErr = AudioFileGetProperty(audioFile,
                                  kAudioFilePropertyInfoDictionary,
                                  &dictionarySize,
                                  &dictionary)

    guard theErr == noErr else { exit(-1) }

    print(dictionary)

    theErr = AudioFileClose(audioFile)

    guard theErr == noErr else { exit(-1) }
}
