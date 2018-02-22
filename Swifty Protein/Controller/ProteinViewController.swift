//
//  ProteinViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit
import SceneKit

class ProteinViewController: UIViewController {
    
    @IBOutlet weak var proteinView: GraphNodeView!
    @IBOutlet weak var headerDisplayer: ProteinHeaderDisplayerView!
    @IBOutlet weak var atomDisplayerView: AtomDisplayerView!
    
    var protein: (header: ProteinHeader, data: ProteinData)?
    var atoms: [String: Atom] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerDisplayer.header = protein?.header
        self.headerDisplayer.shown = false
        self.atomDisplayerView.shown = false
        self.navigationItem.title = protein?.header.id
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "model", style: .plain, target: nil, action: nil)
        self.proteinView.sceneBackground = UIColor.lightGray
        if let data = self.protein?.data {
            for atom in data.atoms {
                self.atoms["\(atom.id)"] = atom
            }
        }
        self.proteinView.dataSource = self
        self.proteinView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btShare(_ sender: Any) {
        let shot = proteinView.sceneView.snapshot()
        let shareVC = UIActivityViewController(activityItems: [shot, "Share"], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func btShowProteinHeader(_ sender: Any) {
        if self.atomDisplayerView.shown {
            self.atomDisplayerView.animate(shown: false)
        }
        self.headerDisplayer.animate(shown: !self.headerDisplayer.shown)
    }
}

extension ProteinViewController: GraphNodeViewDataSource {
    func namesOfAllNodes(in graphNodeView: GraphNodeView) -> Set<String> {
        return Set<String>(self.atoms.keys.map({"\($0)"}))
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, linksForNodeNamed name: String) -> Set<String> {
        guard let atom = self.atoms[name] else {
            return []
        }
        return Set<String>(atom.conects.map({"\($0)"}))
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, modelForNodeNamed name: String) -> SCNNode {
        guard let atom = self.atoms[name] else {
            return (self as GraphNodeViewDataSource).graphNodeView(graphNodeView, modelForNodeNamed: name)
        }
        let sphere = SCNSphere(radius: CGFloat(atom.radius) / 2)
        sphere.materials.first?.diffuse.contents = AtomManager.shared.atomColors[atom.symbol] ?? AtomManager.shared.unknownColor
        let node = SCNNode(geometry: sphere)
        return node
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, positionForNodeNamed name: String) -> SCNVector3? {
        guard let atom = self.atoms[name] else {
            return nil
        }
        let distanceMult: Float = 1.3
        return SCNVector3(distanceMult * atom.x,
                          distanceMult * atom.y,
                          distanceMult * atom.z)
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, informationAboutNodeNamed name: String) -> [String: Any] {
        guard let atom = self.atoms[name] else {
            return [:]
        }
        return [
            "id": atom.id,
            "identifier": atom.identifier,
            "symbol": atom.symbol,
            "coord_x": atom.x,
            "coord_y": atom.y,
            "coord_z": atom.z
        ]
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, linkPropertyForLinkFromNodeNamed name: String, toNodeNamed target: String) -> GraphNodeView.LinkProperty? {
        guard let atom = self.atoms[name] else {
            return nil
        }
        return GraphNodeView.LinkProperty(lineShape: .round,
                                          lineWidth: 0.15,
                                          color: AtomManager.shared.atomColors[atom.symbol] ?? AtomManager.shared.unknownColor,
                                          arrowShaped: false,
                                          startingDistance: 0.0, endingDistance: 0.5)
    }
}

extension ProteinViewController: GraphNodeViewDelegate {
    
    func graphNodeView(_ graphNodeView: GraphNodeView, selectedNodeNamed name: String?) {
        if self.headerDisplayer.shown {
            self.headerDisplayer.animate(shown: false)
        }
        if let name = name {
            guard let atom = self.atoms[name] else {
                return
            }
            self.atomDisplayerView.atom = atom
            self.atomDisplayerView.animate(shown: true)
        } else {
            if self.atomDisplayerView.shown {
                self.atomDisplayerView.animate(shown: false)
            }
        }
    }
    
}

// TODO: Put those shits in other files

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
