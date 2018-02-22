//
//  ProteinTableViewCell.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class ProteinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func takeValue(fromProteinHeader header: ProteinHeader) {
        self.idLabel.text       = header.id
        self.nameLabel.text     = header.name
        self.formulaLabel.text  = header.formula
        self.activityIndicator.isHidden = true
    }
    
    func takeValue(fromLoadingId id: String) {
        self.idLabel.text       = id
        self.nameLabel.text     = "Loading..."
        self.formulaLabel.text  = ""
        self.activityIndicator.startAnimating()
    }
    
    func takeErrorValue(withId id: String) {
        self.idLabel.text       = id
        self.nameLabel.text     = ""
        self.formulaLabel.text  = "loading error"
        self.activityIndicator.isHidden = true
    }
}
