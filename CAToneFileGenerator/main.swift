//
//  main.swift
//  CAToneFileGenerator
//
//  Created by 조수환 on 2023/04/30.
//

import Foundation
import AudioToolbox

let sampleRate: Double = 44100
let duration: Double = 5.0
let filenameFormat = "%0.3f-square.aif"

autoreleasepool {
    guard CommandLine.argc > 1 else {
        print("Usage: CAToneFileGenerator n\n(where n is tone in Hz)")
        exit(0)
    }

    guard let hz = try? Double(CommandLine.arguments[1], format: .number),
        hz > 0 else {
        fatalError()
    }


    print("generating \(hz.formatted(.number.precision(.fractionLength(3)))) hz tone")

    let filename = String(format: filenameFormat, hz)

    let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appending(path: filename)

    var asbd = AudioStreamBasicDescription(mSampleRate: sampleRate,
                                           mFormatID: kAudioFormatLinearPCM,
                                           mFormatFlags: kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                                           mBytesPerPacket: 2,
                                           mFramesPerPacket: 1,
                                           mBytesPerFrame: 2,
                                           mChannelsPerFrame: 1,
                                           mBitsPerChannel: 16,
                                           mReserved: 0)

    var audioFile: AudioFileID?

    var audioErr = AudioFileCreateWithURL(fileURL as CFURL,
                                          kAudioFileAIFFType,
                                          &asbd,
                                          .eraseFile,
                                          &audioFile)

    guard audioErr == noErr,
          let audioFile = audioFile else { fatalError() }

    let maxSampleCount = Int64(sampleRate * duration)
    var sampleCount: Int64 = 0
    var bytesToWrite: UInt32 = 2
    let wavelengthInSamples = Int(sampleRate / hz)
    
    while sampleCount < maxSampleCount {
        for i in 0..<wavelengthInSamples {
            var sample: Int16 = squareWaveSample(wavelengthInSamples, i)
            audioErr = AudioFileWriteBytes(audioFile,
                                           false,
                                           sampleCount * 2,
                                           &bytesToWrite,
                                           &sample)
            assert(audioErr == noErr)

            sampleCount += 1
        }
    }

    audioErr = AudioFileClose(audioFile)
    assert(audioErr == noErr)

    print("wrote \(sampleCount) samples")
}

func squareWaveSample(_ wavelengthInSamples: Int, _ index: Int) -> Int16 {
    if index < wavelengthInSamples / 2 {
        return .max.bigEndian
    } else {
        return .min.bigEndian
    }
}

func sawtoothWaveSample(_ wavelengthInSamples: Int, _ index: Int) -> Int16 {
    let maxValue = Double(Int16.max)
    let ratio = Double(index) / Double(wavelengthInSamples)
    return Int16(ratio * (maxValue * 2) - maxValue).bigEndian
}

func sineWaveSample(_ wavelengthInSamples: Int, _ index: Int) -> Int16 {
    let maxValue = Double(Int16.max)
    let ratio = Double(index) / Double(wavelengthInSamples)

    return Int16(sin(2.0 * .pi * ratio) * maxValue)
}
