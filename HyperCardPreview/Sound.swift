//
//  Sound.swift
//  HyperCardPreview
//
//  Created by Pierre Lorenzi on 23/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import HyperCardCommon


/// A raw sound data, like in the old 'snd ' resources
struct Sound {
    
    var sampleRate: Double
    var samples: [Int16]
}


extension Sound {
    
    /// There are two formats of sound resources. The 2dn was reserved to HyperCard
    /// and was quickly deprecated.
    private enum ResourceFormat {
        case format1
        case format2
    }
    
    /// Offset of the commands, which depends on the format
    private static let commandCountOffsets: [ResourceFormat: Int] = [
        ResourceFormat.format1: 0xA,
        ResourceFormat.format2: 0x4
    ]
    
    /// According to the specification, sound resources are a sequence of commands that
    /// are executed in turn to procude the final sound, like 'play at that pitch for
    /// that many seconds'. But in reality, almost of them them have only one command:
    /// either 'play sample' or 'use sample', which both play a raw sound data.
    ///
    /// Strangely, there is sometimes a null command at first position, which is supposed
    /// to to nothing. But when we look in the assembly, this command is used to tell
    /// that the 2nd command of the list must be replaced by 'use sample'. Apple sound
    /// system was quite a mess.
    private static let validCommandLists: Set<[Int]> = [
        [bufferCommand],
        [soundCommand],
        [nullCommand, bufferCommand],
        [nullCommand, soundCommand]
    ]
    
    /// Null command, it does nothing
    private static let nullCommand = 0
    
    /// Command to use a sample in a channel
    private static let bufferCommand = 80
    
    /// Command to play a sample
    private static let soundCommand = 81
    
    /// Mask to remove the highest bit of a command, which is activated to tell that
    /// the command points to a raw data.
    private static let commandMask = 0x7FFF
    
    private static let commandLength = 8
    
    /// The header of the sound data can have several formats.
    private enum SoundFormat: Equatable {
        case standard
        case extended
        case compressed
        case other(Int)
    }
    
    /// Frequencies are given by numbers
    private static let middleCFrequencyNumber = 60
    
    /// Algorithm used to compress a compressed sound
    private enum CompressionType {
        
        case notCompressed
        case threeToOne
        case sixToOne
        case otherID(Int)
        case otherFormat(NumericName)
    }
    
    /// Builds a sound by parsing the content of a 'snd ' resource
    init?(fromResourceData data: DataRange) {
        
        /* Check the format */
        guard let format = Sound.readResourceFormat(in: data) else {
            return nil
        }
        
        /* Read the number of commands */
        let commandCountOffset = Sound.commandCountOffsets[format]!
        let commandCount = data.readUInt16(at: commandCountOffset)
        guard commandCount > 0 else {
            return nil
        }
        
        /* Check if the sequence of commands is valid */
        let commandOffset = commandCountOffset + 2
        let commandList: [Int] = (0..<commandCount).map({
            data.readUInt16(at: commandOffset + $0 * Sound.commandLength)
                & Sound.commandMask })
        guard Sound.validCommandLists.contains(commandList) else {
            return nil
        }
        
        /* Compute the offset to the sound data (header + samples). According to the
         specification, it should be read in a field, but in the assembly, they just
         go for it after the commands. */
        let soundOffset = commandOffset + commandCount * Sound.commandLength
        let soundData = DataRange(sharedData: data.sharedData, offset: data.offset + soundOffset, length: data.length - soundOffset)
        guard let sound = Sound.readSound(in: soundData) else {
            return nil
        }
        
        self = sound
    }
    
    private static func readResourceFormat(in data: DataRange) -> ResourceFormat? {
        
        let formatNumber = data.readUInt16(at: 0)
        
        switch formatNumber {
            
        case 1:
            return ResourceFormat.format1
            
        case 2:
            return ResourceFormat.format2
            
        default:
            return nil
        }
    }
    
    private static func readSound(in data: DataRange) -> Sound? {
        
        /* Check the format of the header before parsing */
        let soundFormat = readSoundFormat(in: data)
        
        switch soundFormat {
            
        case .standard:
            return self.readStandardSound(in: data)
            
        case .compressed:
            return self.readCompressedSound(in: data)
            
        default:
            return nil
        }
        
    }
    
    private static func readSoundFormat(in data: DataRange) -> SoundFormat {
        
        let formatNumber = data.readUInt8(at: 0x14)
        
        switch formatNumber {
            
        case 0x0:
            return SoundFormat.standard
            
        case 0xFF:
            return SoundFormat.extended
            
        case 0xFE:
            return SoundFormat.compressed
            
        default:
            return SoundFormat.other(formatNumber)
        }
    }
    
    private static func readStandardSound(in data: DataRange) -> Sound? {
        
        /* Read the sound parameters */
        let sampleCount = data.readUInt32(at: 0x4)
        let sampleRate = readSampleRate(in: data)
        
        /* Read the samples */
        let sampleData = DataRange(sharedData: data.sharedData, offset: data.offset + 0x16, length: sampleCount)
        let samples = readRawData(sampleData, sampleCount: sampleCount)
        
        return Sound(sampleRate: sampleRate, samples: samples)
    }
    
    private static func readSampleRate(in data: DataRange) -> Double {
        
        /* The sample rate is in units of 1/65536 */
        let sampleRateValue = data.readUInt32(at: 0x8)
        let sampleRate = Double(sampleRateValue) / 65536.0
        
        /* The sample rate must be set so the base frequency is at middle C,
         as HyperCard played the sounds (it was special to HyperCard). */
        let baseFrequencyNumber = data.readUInt8(at: 0x15)
        let frequencyRatio = pow(2.0, Double(Sound.middleCFrequencyNumber - baseFrequencyNumber) / 12.0)
        let hyperCardSampleRate = sampleRate * frequencyRatio
        
        return hyperCardSampleRate
    }
    
    private static func readRawData(_ data: DataRange, sampleCount: Int) -> [Int16] {
        
        /* Parse the samples */
        let samplesValues = (0..<sampleCount).lazy.map({ data.readUInt8(at: $0) })
        
        /* Convert the samples to 16 bits */
        let zero: Int16 = 0x80
        let factor: Int16 = 0x100
        let samples: [Int16] = samplesValues.map({ (Int16(exactly: $0)! - zero) * factor })
        
        return samples
    }
    
    private static func readCompressedSound(in data: DataRange) -> Sound? {
        
        /* Read the compression algorithm that was used */
        guard let compressionType = readCompressionType(in: data) else {
            return nil
        }
        
        /* Read the sound parameters */
        let channelCount = data.readUInt32(at: 0x4)
        let frameCount = data.readUInt32(at: 0x16)
        let sampleRate = readSampleRate(in: data)
        
        /* Decode the samples */
        let compressedData = DataRange(sharedData: data.sharedData, offset: data.offset + 0x40, length: data.length - 0x40)
        guard let samples = readCompressedData(compressedData, compressionType: compressionType, channelCount: channelCount, frameCount: frameCount) else {
            return nil
        }
        
        return Sound(sampleRate: sampleRate, samples: samples)
    }
    
    private static func readCompressionType(in data: DataRange) -> CompressionType? {
        
        let compressionID = data.readSInt16(at: 0x38)
        
        switch compressionID {
            
        case -2:
            /* variableCompression, it was not managed by the Sound Manager */
            return nil
            
        case -1:
            /* fixedCompression: it means we must read the algorithm in another
             redundant field */
            return readCompressionFormat(in: data)
            
        case 0:
            return .notCompressed
            
        case 3:
            return .threeToOne
            
        case 4:
            return .sixToOne
            
        default:
            return .otherID(compressionID)
        }
    }
    
    private static func readCompressionFormat(in data: DataRange) -> CompressionType {
        
        let compressionFormatValue = data.readUInt32(at: 0x28)
        let compressionFormat = NumericName(value: compressionFormatValue)
        
        switch compressionFormat {
            
        case NumericName(string: "NONE"):
            return CompressionType.notCompressed
            
        case NumericName(string: "MAC3"):
            return CompressionType.threeToOne
            
        case NumericName(string: "MAC6"):
            return CompressionType.sixToOne
            
        default:
            return CompressionType.otherFormat(compressionFormat)
        }
    }
    
    private static func readCompressedData(_ data: DataRange, compressionType: CompressionType, channelCount: Int, frameCount: Int) -> [Int16]? {
        
        switch compressionType {
            
        case .notCompressed:
            return readRawData(data, sampleCount: frameCount)
            
        case .threeToOne:
            /* Take only the first channel */
            return MaceCompressionType.uncompressSound(in: data, type: MaceCompressionType.threeToOne, frameCount: frameCount, channelCount: channelCount)[0]
            
        case .sixToOne:
            /* Take only the first channel */
            return MaceCompressionType.uncompressSound(in: data, type: MaceCompressionType.sixToOne, frameCount: frameCount, channelCount: channelCount)[0]
            
        default:
            return nil
        }
    }
}
