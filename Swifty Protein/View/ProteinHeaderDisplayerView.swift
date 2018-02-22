//
//  ProteinHeaderDisplayerView.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/22/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class ProteinHeaderDisplayerView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var initialDateLabel: UILabel!
    @IBOutlet weak var modifiedDateLabel: UILabel!
    
    weak var header: ProteinHeader? {
        didSet {
            self.reloadInfos()
        }
    }
    
    var shown: Bool = false {
        didSet {
            if self.shown {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height / 2)
                self.transform = self.transform.scaledBy(x: 1.0, y: 0.001)
            }
        }
    }
    
    func animate(shown: Bool) {
        UIView.animate(withDuration: 0.4,
                       delay: 0.1,
                       options: .curveEaseInOut,
                       animations: {
                        self.shown = shown
        })
    }
    
    func reloadInfos() {
        guard let header = self.header else {
            return
        }
        self.nameLabel.text = "name: \(header.name)"
        self.formulaLabel.text = "formula: \(header.formula)"
        self.weightLabel.text = "weight: \(header.weight)"
        self.typeLabel.text = "type: \(header.type)"
        self.initialDateLabel.text = "created in \(header.initialDate.toString(withFormat: "yyyy"))"
        if header.initialDate != header.modifiedDate {
            self.modifiedDateLabel.text = "modified in \(header.modifiedDate.toString(withFormat: "yyyy"))"
        } else {
            self.modifiedDateLabel.text = ""
        }
    }
    
}
