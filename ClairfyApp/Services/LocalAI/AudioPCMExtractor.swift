//
//  AudioPCMExtractor.swift
//  ClairfyApp
//
//  Descodifica .m4a (ou outro formato suportado por AVFoundation) para **PCM float32 mono** a 16 kHz,
//  alinhado ao pré-processamento típico de modelos de áudio (Gemma / mtmd).
//

import AVFoundation
import Foundation

enum AudioPCMExtractor {
    /// Converte o ficheiro de áudio para amostras float32 mono @ `targetSampleRate` (ex.: 16000).
    static func floatPCMMono(url: URL, targetSampleRate: Double = 16_000) throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let srcFormat = file.processingFormat

        guard let dstFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: targetSampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw LocalInferenceError.audioDecodeFailed
        }

        guard let converter = AVAudioConverter(from: srcFormat, to: dstFormat) else {
            throw LocalInferenceError.audioDecodeFailed
        }

        file.framePosition = 0
        let maxFrames = AVAudioFrameCount(file.length)
        guard let srcBuffer = AVAudioPCMBuffer(pcmFormat: srcFormat, frameCapacity: maxFrames) else {
            throw LocalInferenceError.audioDecodeFailed
        }
        try file.read(into: srcBuffer)

        let outCapacity = AVAudioFrameCount(
            ceil(Double(srcBuffer.frameLength) * targetSampleRate / srcFormat.sampleRate) + 4096
        )
        guard let dstBuffer = AVAudioPCMBuffer(pcmFormat: dstFormat, frameCapacity: outCapacity) else {
            throw LocalInferenceError.audioDecodeFailed
        }

        var error: NSError?
        var consumed = false
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            if consumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            consumed = true
            outStatus.pointee = .haveData
            return srcBuffer
        }

        converter.convert(to: dstBuffer, error: &error, withInputFrom: inputBlock)
        if let error {
            throw LocalInferenceError.audioDecodeFailed
        }

        guard let ch = dstBuffer.floatChannelData else {
            throw LocalInferenceError.audioDecodeFailed
        }
        let n = Int(dstBuffer.frameLength)
        guard n > 0 else {
            throw LocalInferenceError.audioDecodeFailed
        }
        return Array(UnsafeBufferPointer(start: ch[0], count: n))
    }
}
