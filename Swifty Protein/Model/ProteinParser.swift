//
//  ProteinParser.swift
//  Swifty Protein
//
//  Created by Arthur Masson on 21/02/2018.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

class ProteinHeaderParser: NSObject, XMLParserDelegate {
    
    let xmlParser: XMLParser
    
    var id: String
    var name: String?
    var formula: String?
    var type: String?
    var initialDate: String?
    var modifiedDate: String?
    var weight: String?
    
    var currentPath: [String] = []
    enum ActualReading {
        case name
        case formula
        case type
        case initialDate
        case modifiedDate
        case weight
        case nothingInteresting
    }
    var actualReading = ActualReading.nothingInteresting
    
    init?(id: String, contentOf url: URL) {
        self.id = id
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }
        self.xmlParser = parser
        super.init()
        self.xmlParser.delegate = self
    }
    
    func parse() {
        self.xmlParser.parse()
    }
    
    func getProteinHeader() -> ProteinHeader? {
        if let name = self.name,
            let formula = self.formula,
            let type = self.type,
            let initialDate_str = self.initialDate,
            let modifiedDate_str = self.modifiedDate,
            let weight_str = self.weight,
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
            return proteinHeader
        } else {
            return nil
        }
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        self.currentPath.append(elementName)
        if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:name"] {
            self.actualReading = .name
        } else if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:formula"] {
            self.actualReading = .formula
        } else if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:pdbx_type"] {
            self.actualReading = .type
        } else if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:pdbx_initial_date"] {
            self.actualReading = .initialDate
        } else if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:pdbx_modified_date"] {
            self.actualReading = .modifiedDate
        } else if self.currentPath == ["PDBx:datablock", "PDBx:chem_compCategory", "PDBx:chem_comp", "PDBx:formula_weight"] {
            self.actualReading = .weight
        } else {
            self.actualReading = .nothingInteresting
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        defer {
            if currentPath.last == elementName {
                currentPath.removeLast()
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string.filter({!CharacterSet.whitespacesAndNewlines.contains($0.unicodeScalars.first!)}).isEmpty {
            return
        }
        switch self.actualReading {
        case .name:
            if self.name == nil {
                self.name = string
            } else {
                self.name = self.name! + " " + string
            }
        case .formula:
            if self.formula == nil {
                self.formula = string
            } else {
                self.formula = self.formula! + " " + string
            }
        case .type:
            if self.type == nil {
                self.type = string
            } else {
                self.type = self.type! + " " + string
            }
        case .initialDate:
            if self.initialDate == nil {
                self.initialDate = string
            }
        case .modifiedDate:
            if self.modifiedDate == nil {
                self.modifiedDate = string
            }
        case .weight:
                if self.weight == nil {
                    self.weight = string
            }
        case .nothingInteresting:
            break
        }
    }
}

class ProteinDataParser: NSObject {
    
    unowned let header: ProteinHeader
    var lines: [String]
    var atoms: [Int: Atom] = [:]
    
    init?(header: ProteinHeader, contentsOf url: URL) {
        guard let content = try? String(contentsOf: url) else {
            return nil
        }
        self.header = header
        self.lines = content.components(separatedBy: .newlines)
        super.init()
    }
    
    func parse() {
        lineLoop: for line in self.lines {
            let splits = line.components(separatedBy: .whitespaces).filter{!$0.isEmpty}
            if splits.first == "ATOM" {
                guard splits.count == 12,
                    let id = Int(splits[1]),
                    let x = Float(splits[6]),
                    let y = Float(splits[7]),
                    let z = Float(splits[8]),
                    let radius = Float(splits[9]) else {
                        continue lineLoop
                }
                let atom = Atom(id: id)
                atom.identifier = splits[2]
                atom.symbol = splits[11]
                atom.x = x
                atom.y = y
                atom.z = z
                atom.radius = radius
                self.atoms[id] = atom
            } else if splits.first == "CONECT" {
                let ids = splits.dropFirst().flatMap {Int($0)}
                guard let firstId = ids.first,
                    let atom = self.atoms[firstId] else {
                    continue lineLoop
                }
                for id in ids.dropFirst() {
                    atom.conects.append(id)
                }
            }
        }
    }
    
    func getProteinData() -> ProteinData? {
        let proteinData = ProteinData(header: self.header)
        proteinData.atoms = self.atoms.values.sorted(by: {$0.id < $1.id})
        return proteinData
    }
}
