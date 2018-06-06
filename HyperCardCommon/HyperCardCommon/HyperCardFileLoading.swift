//
//  HyperCardFileLoading.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public extension HyperCardFile {
    
    public convenience init(file: ClassicFile, password possiblePassword: HString? = nil, hackEncryption: Bool = true) throws {
        
        /* Decrypt the header if necessary */
        let dataFork = file.dataFork!
        let decodedHeader: Data? = try HyperCardFile.computeDecodedHeader(in: dataFork, possiblePassword: possiblePassword, hackEncryption: hackEncryption)
        
        /* Check the checksum (must be after decryption) */
        let dataRange = DataRange(sharedData: dataFork, offset: 0, length: dataFork.count)
        let fileReader = HyperCardFileReader(data: dataRange, decodedHeader: decodedHeader)
        guard fileReader.extractStackReader().isChecksumValid() else {
            throw OpeningError.corrupted
        }
        
        /* Start initialization */
        self.init()
        
        /* Build the stack */
        self.stackProperty.lazyCompute { () -> Stack in
            return Stack(fileReader: fileReader)
        }
        
        /* Register the resources */
        self.resourcesProperty.lazyCompute { () -> ResourceRepository? in
            guard let resourceFork = file.resourceFork else {
                return nil
            }
            return ResourceRepository(fromResourceFork: resourceFork)
        }
        
    }
    
    private static func computeDecodedHeader(in dataFork: Data, possiblePassword: HString?, hackEncryption: Bool) throws -> Data? {
        
        /* Check if the stack header is encrypted by making a fake header reader */
        let dataRange = DataRange(sharedData: dataFork, offset: 0, length: dataFork.count)
        let stackReader = StackBlockReader(data: dataRange, decodedHeader: nil)
        guard stackReader.readPrivateAccess() else {
            return nil
        }
        
        let decrypter = StackBlockDecrypter(stackBlockData: dataRange)
        
        /* Hack is requested */
        if hackEncryption, let decodedData = decrypter.hack() {
            return decodedData
        }
        
        /* Use the password if given */
        guard let password = possiblePassword else {
            throw OpeningError.missingPassword
        }
        guard let decodedData = decrypter.decrypt(withPassword: password) else {
            throw OpeningError.wrongPassword
        }
        
        return decodedData
    }
    
}
