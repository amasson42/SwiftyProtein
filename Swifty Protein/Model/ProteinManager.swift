//
//  ProteinManager.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/16/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

protocol ProteinManagerDelegate: class {
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingHeader header: ProteinHeader)
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingData data: ProteinData)
    func proteinManager(_ proteinManager: ProteinManager, error: ProteinManager.LoadingError, loading id: String)
}

extension ProteinManagerDelegate {
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingHeader header: ProteinHeader) {}
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingData data: ProteinData) {}
    func proteinManager(_ proteinManager: ProteinManager, error: ProteinManager.LoadingError, loading id: String) {}
}

class ProteinManager: NSObject {
    
    enum LoadingError: Error {
        // TODO: add other possibles errors
        case unexistingID
    }
    
    weak var delegate: ProteinManagerDelegate?
    
    private override init () {}
    static let shared: ProteinManager = ProteinManager()
    
    // MARK: Parser values
    var parserElement: String = ""
    var parserGetIt: Bool = false
    
    /** the names of all the protein we can display. It's the content of the provided text file for the project */
    public static let allProteinIDs: [String] = {
        guard let textUrl = Bundle.main.url(forResource: "LigandsNames", withExtension: "txt"),
            let fileContent = try? String(contentsOf: textUrl, encoding: .utf8) else {
                return []
        }
        return fileContent.components(separatedBy: .newlines)
    }()
    
    func loadProteinHeader(id: String) {
        guard let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id)) else {
            self.delegate?.proteinManager(self, error: .unexistingID, loading: id)
            return
        }
        // TODO: load and parse the protein header
        let header = ProteinHeader(ID: id)
        self.delegate?.proteinManager(self, finishedLoadingHeader: header)
    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader) {
        // TODO: load and parse protein from the name
        let data = ProteinData(ID: header.ID)
        self.delegate?.proteinManager(self, finishedLoadingData: data)
    }
    
    func getURLHeader(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + ".xml"))!
    }
    
    func getURLData(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + "_ideal.pdb"))!
    }
    
}

extension ProteinManager: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName == "PDBx:name" {
            parserElement = "name"
            parserGetIt = true
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if parserGetIt {
            print("\(parserElement) \(string)")
            parserGetIt = false
        }
    }
    //    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    //        print("Did end element: \(elementName)")
    //    }
    //    func parserDidEndDocument(_ parser: XMLParser) {
    //        print("Completed parsing document")
    //    }
    
}
