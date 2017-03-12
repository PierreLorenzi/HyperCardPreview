//
//  File.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 27/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class HyperCardFile: ClassicFile {
    
    public var stack: Stack {
        return FileStack(fileContent: self.parsedData, resources: self.resourceRepository)
    }
    
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
    
    public enum Version: Int {
        case notHyperCardStack
        case preReleaseV1
        case v1
        case preReleaseV2
        case v2
    }
    
}
