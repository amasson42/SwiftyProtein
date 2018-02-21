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
        // TODO: add other possibles errors
        case unexistingID
        case incompleteFile
        case networkError
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
        DispatchQueue.global(qos: .background).async {
            let headerUrl = self.getURLHeader(ofID: id)
            guard let parser = XMLParser(contentsOf: headerUrl) else {
                completion(nil, .unexistingID)
                return
            }
            let headerParser = ProteinHeaderParser()
            parser.delegate = headerParser
            parser.parse()
            if let name = headerParser.name,
                let formula = headerParser.formula,
                let type = headerParser.type,
                let initialDate_str = headerParser.initialDate,
                let modifiedDate_str = headerParser.modifiedDate,
                let weight_str = headerParser.weight,
                let initialDate = Date.date(fromString: initialDate_str, withFormat: "yyyy-MM-dd"),
                let modifiedDate = Date.date(fromString: modifiedDate_str, withFormat: "yyyy-MM-dd"),
                let weight = Float(weight_str) {
                let proteinHeader = ProteinHeader(id: id)
                proteinHeader.name = name
                proteinHeader.formula = formula
                proteinHeader.type = type
                proteinHeader.initialDate = initialDate
                proteinHeader.modifiedDate = modifiedDate
                proteinHeader.weight = weight
                completion(proteinHeader, nil)
            } else {
                completion(nil, .incompleteFile)
            }
        }
    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader, completion: @escaping (ProteinData?, ProteinManager.LoadingError?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let dataUrl = self.getURLData(ofID: header.id)
            do {
                let content = try String(contentsOf: dataUrl)
                let dataParser = ProteinDataParser(header: header, contentsOf: content)
                dataParser.parse()
                if let data = dataParser.getProteinData() {
                    completion(data, nil)
                } else {
                    completion(nil, .incompleteFile)
                }
            } catch {
                completion(nil, .networkError)
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
