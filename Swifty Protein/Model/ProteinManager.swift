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

class ProteinManager: ProteinParser {
    
    private override init () {}
    static let shared: ProteinManager = ProteinManager()
    
    /** the names of all the protein we can display. It's the content of the provided text file for the project */
    public static let allProteinIDs: [String] = {
        guard let textUrl = Bundle.main.url(forResource: "LigandsNames", withExtension: "txt"),
            let fileContent = try? String(contentsOf: textUrl, encoding: .utf8) else {
                return []
        }
        return fileContent.components(separatedBy: .newlines)
    }()
    
    func loadProteinHeader(id: String, completion: @escaping (ProteinHeader?, ProteinParser.LoadingError?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let header = ProteinHeader(ID: id)
            header.name = "name\(id)"
            header.formula = "formula\(id)"
            completion(header, nil)
        }
        return;
        queue.async {
            guard let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id)) else {
                completion(nil, .unexistingID)
                return
            }
 
            parser.delegate = self
            parser.parse()
        //            DispatchQueue.main.async {
        //            }
        }
//        let header = ProteinHeader(ID: id)
        
    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader, completion: @escaping (ProteinData?, ProteinParser.LoadingError?) -> ()) {
        // TODO: load and parse protein from the name
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let data = ProteinData(ID: header.ID)
            completion(data, nil)
        }

    }
    
    func getURLHeader(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + ".xml"))!
    }
    
    func getURLData(ofID ID: String) -> URL {
        return (URL(string: "https://files.rcsb.org/ligands/view/" + ID + "_ideal.pdb"))!
    }
    
}

class ProteinParser: NSObject, XMLParserDelegate {
    
    enum LoadingError: Error {
        // TODO: add other possibles errors
        case unexistingID
    }
    
    var parserElement: String   = ""
    var parserGetIt: Bool       = false
    var id: String?             = nil
    var name: String            = ""
    var formula: String         = ""
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
        case "PDBx:chem_comp":
            self.id = attributeDict["id"]
        case "PDBx:name":
            parserElement = "name"
            parserGetIt = true
        case "PDBx:formula":
            parserElement = "formula"
            parserGetIt = true
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if parserGetIt {
            switch parserElement {
            case "name":
                name = string
            case "formula":
                formula = string
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if parserGetIt && elementName == "PDBx:formula" {
            let currentProt = ProteinHeader(ID: self.id!)
            currentProt.name        = name
            currentProt.formula     = formula
            parserGetIt             = false
//            print(currentProt.ID, currentProt.name, currentProt.formula)
            name = ""
            formula = ""
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
    
}
