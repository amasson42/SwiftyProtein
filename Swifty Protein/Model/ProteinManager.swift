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
    var completionHandler: ((ProteinHeader?, ProteinManager.LoadingError?) -> ())?
    enum LoadingError: Error {
        // TODO: add other possibles errors
        case unexistingID
    }
    
    var parserElement: String   = ""
    var parserGetIt: Bool       = false
    var id: String?             = nil
    var name: String            = ""
    var formula: String         = ""
    
    /** the names of all the protein we can display. It's the content of the provided text file for the project */
    public static let allProteinIDs: [String] = {
        guard let textUrl = Bundle.main.url(forResource: "LigandsNames", withExtension: "txt"),
            let fileContent = try? String(contentsOf: textUrl, encoding: .utf8) else {
                return []
        }
        return fileContent.components(separatedBy: .newlines)
    }()
    
//    private func loadHeader(id: String, completion: @escaping (ProteinHeader?, ProteinParser.LoadingError?) -> ()) {
//        guard let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id)) else {
//            completion(nil, .unexistingID)
//            return
//        }
//        let header = ProteinHeader(ID: id)
//        completion(header, nil)
//    }
//
//    func loadProteinHeader(id: String) {
//        loadHeader(id: id) { (proteinHeader, loadingError) in
//            if loadingError == nil {
//                let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id))!
//                parser.delegate = self
//                parser.parse()
//                proteinHeader?.name        = self.name
//                proteinHeader?.formula     = self.formula
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//
//                }
//            }
//        }
//    }

    func loadProteinHeader(id: String, completion: @escaping (ProteinHeader?, ProteinManager.LoadingError?) -> ()) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            let header = ProteinHeader(ID: id)
//            header.name = "name\(id)"
//            header.formula = "formula\(id)"
//            completion(header, nil)
//        }
        completionHandler = completion
        queue.async {
            guard let parser = XMLParser(contentsOf: self.getURLHeader(ofID: id)) else {
                completion(nil, .unexistingID)
                return
            }
            parser.delegate = self
            parser.parse()
        }

    }
    
    /** load a protein with the given name from the text file */
    func loadProteinData(header: ProteinHeader, completion: @escaping (ProteinData?, ProteinManager.LoadingError?) -> ()) {
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

extension ProteinManager: XMLParserDelegate {
    
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
//                print("name '\(string)'")
                name = string
                parserElement = ""
            case "formula":
                formula = string
                parserElement = ""
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
            completionHandler!(currentProt, nil)
            parserGetIt             = false
            print(currentProt.ID, currentProt.name, currentProt.formula)
            name = ""
            formula = ""

        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
    
}
