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
    
    var protein: (header: ProteinHeader, data: ProteinData)?
    var atoms: [String: Atom] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        sphere.materials.first?.diffuse.contents = ProteinData.atomColors[atom.symbol] ?? UIColor.lightGray
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
                                          color: ProteinData.atomColors[atom.symbol] ?? UIColor.lightGray,
                                          arrowShaped: false,
                                          startingDistance: 0.0, endingDistance: 0.5)
    }
}

extension ProteinViewController: GraphNodeViewDelegate {
    
    func graphNodeView(_ graphNodeView: GraphNodeView, selectedNodeNamed name: String) {
        guard let atom = self.atoms[name] else {
            return
        }
        
    }
    
}
