//
//  ProteinClass.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import Foundation

// https://files.rcsb.org/ligands/view/**.xml

class ProteinHeader {
    var ID:         String
    
    init(ID: String) {
        self.ID = ID
    }
}

class ProteinData {
    
    var ID:         String      //  also the IDs given in the project txt file
    var available:  Bool        = false     //  if the protein is available on RCSB (download test)
    var name:       String      = ""
    var formula:    String      = ""
    var atoms:      [Atom]      = []
    var conects:    [Conect]    = []
    
//    init (ID: String, available: Bool, name:String, formula: String, atoms: [Atom], conects: [Conect]) {
    init (ID: String) {
        self.ID         = ID
//        self.available  = available
//        self.name       = name
//        self.formula    = formula
//        self.atoms      = atoms
//        self.conects    = conects
    }
    
}

// https://files.rcsb.org/ligands/view/**_ideal.pdb
// all atoms are linked in the serial order
class Atom {
    
    var serial:     Int
    var symbol:     String
    var resName:    String      // TODO: useful for new chain?
    var chainID:    String      // if chainID changes, a new chain of links begins
    var x:          Float
    var y:          Float
    var z:          Float
    
    init (serial: Int, symbol: String, resName: String, chainID: String, x: Float, y: Float, z: Float) {
        self.serial     = serial
        self.symbol     = symbol
        self.resName    = resName
        self.chainID    = chainID
        self.x          = x
        self.y          = y
        self.z          = z
    }
}

// supplementary links between atoms. From 'origin' to 'target(s)'. Atoms are identified by their serial
class Conect {
    
    var origin:     Int
    var targets:    [Int]
    
    init (origin: Int, targets: [Int]) {
        self.origin     = origin
        self.targets    = targets
    }
}
