//
//  ProteinManager.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/16/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

let qos                 = DispatchQoS.background.qosClass
let queue               = DispatchQueue.global(qos: qos)

class ProteinManager: NSObject {
    
    private override init () {}
    static let shared: ProteinManager = ProteinManager()
    
    enum LoadingError: Error {
        case unexistingID
        case incompleteFile
    }
    
    /** the names of all the protein we can display. It's the content of the provided text file for the project */
    public static let allProteinIDs: [String] = {
        guard let textUrl = Bundle.main.url(forResource: "LigandsNames", withExtension: "txt"),
            let fileContent = try? String(contentsOf: textUrl, encoding: .utf8) else {
                return []
        }
        return fileContent.components(separatedBy: .newlines)
    }()
    
    func loadProteinHeader(id: String, completion: @escaping (ProteinHeader?, ProteinManager.LoadingError?) -> ()) {
        networkCount += 1
        DispatchQueue.global(qos: .background).async {
            defer {networkCount -= 1}
            let headerUrl = self.getURLHeader(ofID: id)
            guard let parser = ProteinHeaderParser(id: id, contentOf: headerUrl) else {
                return completion(nil, .unexistingID)
            }
            parser.parse()
            if let header = parser.getProteinHeader() {
                completion(header, nil)
            } else {
                completion(nil, .incompleteFile)
            }
        }
    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader, completion: @escaping (ProteinData?, ProteinManager.LoadingError?) -> ()) {
        networkCount += 1
        DispatchQueue.global(qos: .background).async {
            defer {networkCount -= 1}
            let dataUrl = self.getURLData(ofID: header.id)
            guard let parser = ProteinDataParser(header: header, contentsOf: dataUrl) else {
                return completion(nil, .unexistingID)
            }
            parser.parse()
            if let data = parser.getProteinData() {
                completion(data, nil)
            } else {
                completion(nil, .incompleteFile)
            }
        }
    }
    
    func getURLHeader(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + ".xml"))!
    }
    
    func getURLData(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + "_ideal.pdb"))!
    }
    
}
