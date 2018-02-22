//
//  AtomDisplayerView.swift
//  Swifty Protein
//
//  Created by Arthur MASSON on 2/22/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class AtomDisplayerView: UIView, UITableViewDataSource {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var atomInformationView: UITableView!
    
    weak var atom: Atom? {
        didSet {
            self.reloadInfos()
        }
    }
    
    var shown: Bool = false {
        didSet {
            if self.shown {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height / 2)
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
        if let atom = self.atom,
            let infos = AtomManager.shared.atomsInformations[atom.symbol],
            let name = infos["name"] as? String,
            let symbol = infos["symbol"] as? String {
            self.titleLabel.text = "\(name) - \(symbol)"
        }
        self.atomInformationView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let atom = self.atom,
            let informations = AtomManager.shared.atomsInformations[atom.symbol] else {
                return 1
        }
        return informations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath)
        
        if let atom = self.atom,
            let informations = AtomManager.shared.atomsInformations[atom.symbol] {
            let pair = informations[informations.index(informations.startIndex, offsetBy: indexPath.row)]
            cell.textLabel?.text = pair.key
            cell.detailTextLabel?.text = (pair.value as? CustomStringConvertible)?.description ?? "nope"
        } else {
            cell.textLabel?.text = "unknown atom"
            cell.detailTextLabel?.text = "lol sorry"
        }
        
        return cell
    }
    
}
