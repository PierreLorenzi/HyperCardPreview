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
    
    var sampleCount: Int
    var sampleRate: Double
    var sampleData: DataRange
}


extension Sound {
    
    /// There are two formats of sound resources. The 2dn was reserved to HyperCard
    /// and was quickly deprecated.
    private enum Format {
        case format1
        case format2
    }
    
    /// Offset of the commands, which depends on the format
    private static let commandCountOffsets: [Format: Int] = [
        Format.format1: 0xA,
        Format.format2: 0x4
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
    private enum HeaderFormat: Equatable {
        case standard
        case extended
        case compressed
        case other(Int)
    }
    
    /// Frequencies are given by numbers
    private static let middleCFrequencyNumber = 60
    
    /// Builds a sound by parsing the content of a 'snd ' resource
    init?(fromResourceData data: DataRange) {
        
        /* Check the format */
        guard let format = Sound.readFormat(in: data) else {
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
    
    private static func readFormat(in data: DataRange) -> Format? {
        
        let formatNumber = data.readUInt16(at: 0)
        
        switch formatNumber {
            
        case 1:
            return Format.format1
            
        case 2:
            return Format.format2
            
        default:
            return nil
        }
    }
    
    private static func readSound(in data: DataRange) -> Sound? {
        
        /* Check the format of the header, we only handle the standard one */
        let headerFormat = readHeaderFormat(in: data)
        guard headerFormat == HeaderFormat.standard else {
            return nil
        }
        
        /* Read the sound parameters */
        let sampleCount = data.readUInt32(at: 0x4)
        let sampleData = DataRange(sharedData: data.sharedData, offset: data.offset + 0x16, length: sampleCount)
        
        /* Read the sample rate, it must be set so the base frequency is at middle C,
         as HyperCard played the sounds (it was special to HyperCard). */
        let sampleRateValue = data.readUInt32(at: 0x8)
        let sampleRate = Double(sampleRateValue) / 65536.0
        let baseFrequencyNumber = data.readUInt8(at: 0x15)
        let frequencyRatio = pow(2.0, Double(Sound.middleCFrequencyNumber - baseFrequencyNumber) / 12.0)
        let hyperCardSampleRate = sampleRate * frequencyRatio
        
        return Sound(sampleCount: sampleCount, sampleRate: hyperCardSampleRate, sampleData: sampleData)
    }
    
    private static func readHeaderFormat(in data: DataRange) -> HeaderFormat {
        
        let formatNumber = data.readUInt8(at: 0x14)
        
        switch formatNumber {
            
        case 0x0:
            return HeaderFormat.standard
            
        case 0xFF:
            return HeaderFormat.extended
            
        case 0xFE:
            return HeaderFormat.compressed
            
        default:
            return HeaderFormat.other(formatNumber)
        }
    }
}
