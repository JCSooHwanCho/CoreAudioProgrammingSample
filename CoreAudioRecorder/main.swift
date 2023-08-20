//
//  main.swift
//  CoreAudioRecorder
//
//  Created by 조수환 on 2023/05/07.
//

import AudioToolbox
import CoreAudioUtil

func MyAQInputCallback(_ userData: UnsafeMutableRawPointer?,
                       _ audioQueue: AudioQueueRef,
                       _ buffer: AudioQueueBufferRef,
                       _ startTime: UnsafePointer<AudioTimeStamp>,
                       _ numPackets: UInt32,
                       _ packetDesription: UnsafePointer<AudioStreamPacketDescription>?) {

}

// 사용자 데이터 초기화
var recorder = MyRecorder()

// format 정보 중 채울 수 있는 것 채우기
var recordFormat = AudioStreamBasicDescription()
recordFormat.mFormatID = kAudioFormatMPEG4AAC
recordFormat.mChannelsPerFrame = 2

// CoreAudio에 필요한 필드 채워달라 요청하기
var propSize = UInt32(MemoryLayout.size(ofValue: recordFormat))
checkError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                  0,
                                  nil,
                                  &propSize,
                                  &recordFormat))

// audioQueue 초기화
var audioQueue: AudioQueueRef!
checkError(
    AudioQueueNewInput(&recordFormat,
                       MyAQInputCallback,
                       &recorder,
                       nil,
                       nil,
                       0,
                       &audioQueue)
)


// Queue를 통해서 정보를 더 채워넣기
var size = UInt32(MemoryLayout.size(ofValue: recordFormat))
checkError(
    AudioQueueGetProperty(audioQueue,
                          kAudioConverterCurrentInputStreamDescription,
                          &recordFormat,
                          &size),
    operation: "Could't get queue's format"
)

guard let myFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                    "output.caf" as CFString,
                                                    .cfurlposixPathStyle,
                                                    false) else {
    try! FileHandle.standardError.write(
        contentsOf: Data("fail to make output file URL".utf8)
    )
    exit(1)
}

checkError(AudioFileCreateWithURL(myFileURL,
                                  kAudioFileCAFType,
                                  &recordFormat,
                                  .eraseFile,
                                  &recorder.recordFile))
