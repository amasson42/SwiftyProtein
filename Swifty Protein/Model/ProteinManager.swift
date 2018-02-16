//
//  ProteinManager.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/16/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

class ProteinManager: NSObject {
    
    private override init () {}
    static let shared: ProteinManager = ProteinManager()
    
    // MARK: Parser values
    var parserElement: String = ""
    var parserGetIt: Bool = false
    
    /** the names of all the protein we can display. It's the content of the provided text file for the project */
    public static let allProteinIDs: [String] = {
        guard let textUrl = URL(string: "https://projects.intra.42.fr/uploads/document/document/312/ligands.txt"),
            let fileContent = try? String(contentsOf: textUrl, encoding: .utf8) else {
                return []
        }
        return fileContent.components(separatedBy: .newlines)
    }()
    
    func loadProteinHeader(id: String) -> ProteinHeader? {
        guard let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id)) else {
            return nil
        }
        // TODO: load and parse the protein header
        return nil
    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader) -> ProteinData? {
        // TODO: load and parse protein from the name
        return nil
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
