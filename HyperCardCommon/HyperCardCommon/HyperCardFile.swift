//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A HyperCard stack, as a parsed file, not as an HyperCard object
public class HyperCardFile: ClassicFile {
    
    public enum ParsingError: Error {
        case notStack
        case privateAccess
    }
    
    public init(path: String) throws {
        
        super.init(path: path)
        
        /* Check if the file is a stack */
        if self.version == .notHyperCardStack {
            throw ParsingError.notStack
        }
        
        /* Check if the stack header is encrypted (we don't handle that) */
        if self.parsedData.stack.privateAccess {
            throw ParsingError.privateAccess
        }
        
    }
    
    /// The stack object contained in the file
    public lazy var stack: Stack = { [unowned self] in
        return Stack(fileContent: self.parsedData, resources: self.resourceRepository)
    }()
    
    /// The data blocks contained in the file
    public var parsedData: HyperCardFileData {
        let data = self.dataFork!
        let dataRange = DataRange(sharedData: data, offset: 0, length: data.count)
        
        switch version {
        case .preReleaseV2, .v2:
            return HyperCardFileData(data: dataRange)
            
        case .preReleaseV1, .v1:
            return HyperCardFileDataV1(data: dataRange)
            
        case .notHyperCardStack:
            fatalError("the data is not a HyperCard Stack")
            
        }
        
    }
    
    /// The version of the stack format: V1 or V2. Parsed here because it must be read before
    /// parsing the file.
    public var version: Version {
        let format = self.dataFork![0x13]
        switch format {
        case 1...7:
            return .preReleaseV1
        case 8:
            return .v1
        case 9:
            return .preReleaseV2
        case 10:
            return .v2
        default:
            return .notHyperCardStack
        }
    }
    
    /// The possible versions of the stack format.
    public enum Version: Int {
        case notHyperCardStack
        case preReleaseV1
        case v1
        case preReleaseV2
        case v2
    }
    
}
