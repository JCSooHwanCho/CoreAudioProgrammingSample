//
//  MyRecorder.swift
//  CoreAudioRecorder
//
//  Created by 조수환 on 2023/07/23.
//

import AudioToolbox

struct MyRecorder {
    var recordFile: AudioFileID?
    var recordPacket: Int64 = 0
    var isRunning: Bool = false
}
