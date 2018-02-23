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
    enum DisplayingStyle: Int {
        case balls = 0
        case ballsnsticks = 1
        case sticks = 2
    }
    var displayingStyle: DisplayingStyle = .ballsnsticks
    var usingEnvironement: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerDisplayer.header = protein?.header
        self.headerDisplayer.shown = false
        self.atomDisplayerView.shown = false
        self.navigationItem.title = protein?.header.id
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "model", style: .plain, target: nil, action: nil)
        self.proteinView.sceneBackground = UIColor.black
        let rotateAction = SCNAction.repeatForever(.rotateBy(x: 0, y: 1, z: 0, duration: 2))
        if let nodes = self.proteinView.sceneView.scene?.rootNode.childNode(withName: "nodes", recursively: true) {
            nodes.runAction(rotateAction)
        }
        if let links = self.proteinView.sceneView.scene?.rootNode.childNode(withName: "links", recursively: true) {
            links.runAction(rotateAction)
        }
        if let data = self.protein?.data {
            for atom in data.atoms {
                self.atoms["\(atom.id)"] = atom
            }
        }
        self.proteinView.dataSource = self
        self.proteinView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
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
    
    @IBAction func changeDisplayingStyle(_ sender: UISegmentedControl) {
        self.displayingStyle = DisplayingStyle(rawValue: sender.selectedSegmentIndex)!
        self.proteinView.reloadData()
    }
    
    @IBAction func switchEnvironement(_ sender: UISwitch) {
        self.usingEnvironement = sender.isOn
        self.proteinView.reloadData()
    }
}

extension ProteinViewController: GraphNodeViewDataSource {
    
    func createEnvNode() -> SCNNode {
        let node = SCNNode()
        
        let ambiantLight = SCNNode()
        ambiantLight.light = SCNLight()
        ambiantLight.light!.type = .ambient
        ambiantLight.light!.intensity *= 0.2
        let spotLight = SCNNode()
        spotLight.light = SCNLight()
        spotLight.light!.type = .spot
        spotLight.light!.spotInnerAngle *= 2
        spotLight.light!.spotOuterAngle *= 2
        spotLight.light!.castsShadow = true
        spotLight.position = SCNVector3(x: 0, y: 0, z: 15)
        let lightPosition = SCNNode()
        lightPosition.eulerAngles.x = -.pi / 3
        lightPosition.addChildNode(ambiantLight)
        lightPosition.addChildNode(spotLight)
        lightPosition.runAction(.repeatForever(.rotateBy(x: 0, y: -1, z: 0, duration: 2)))
        node.addChildNode(lightPosition)
        
        let groundNode = SCNNode(geometry: SCNFloor())
        groundNode.geometry!.materials.first!.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 0.4, alpha: 1.0)
        (groundNode.geometry as! SCNFloor).reflectivity = 0.6
        groundNode.position.y = (self.atoms.values.map({$0.y}).min() ?? 0.0) - 2.0
        node.addChildNode(groundNode)
        
        return node
    }
    
    func namesOfAllNodes(in graphNodeView: GraphNodeView) -> Set<String> {
        var set = Set<String>(self.atoms.keys.map({"\($0)"}))
        if self.usingEnvironement {
            set.insert("env")
        }
        return set
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, linksForNodeNamed name: String) -> Set<String> {
        guard let atom = self.atoms[name] else {
            return []
        }
        if self.displayingStyle == .balls {
            return []
        } else {
            return Set<String>(atom.conects.map({"\($0)"}))
        }
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, modelForNodeNamed name: String) -> SCNNode {
        if name == "env" {
            return self.createEnvNode()
        }
        guard let atom = self.atoms[name] else {
            return (self as GraphNodeViewDataSource).graphNodeView(graphNodeView, modelForNodeNamed: name)
        }
        let node: SCNNode
        switch self.displayingStyle {
        case .balls:
            let sphere = SCNSphere(radius: CGFloat(atom.radius))
            sphere.materials.first?.diffuse.contents = AtomManager.shared.atomColors[atom.symbol] ?? AtomManager.shared.unknownColor
            node = SCNNode(geometry: sphere)
        case .ballsnsticks:
            let color = AtomManager.shared.atomColors[atom.symbol] ?? AtomManager.shared.unknownColor
            let sphere = SCNSphere(radius: CGFloat(atom.radius) / 2)
            sphere.materials.first?.diffuse.contents = color
            node = SCNNode(geometry: sphere)
        case .sticks:
            node = SCNNode()
        }
        return node
    }
    
    func graphNodeView(_ graphNodeView: GraphNodeView, positionForNodeNamed name: String) -> SCNVector3? {
        if name == "env" {
            return SCNVector3Zero
        }
        guard let atom = self.atoms[name] else {
            return nil
        }
        let distanceMult: Float = 1.0
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
        let lineWidth: Float
        switch self.displayingStyle {
        case .balls:
            lineWidth = 0.0
        case .ballsnsticks:
            lineWidth = 0.15
        case .sticks:
            lineWidth = 0.075
        }
        return GraphNodeView.LinkProperty(lineShape: .round,
                                          lineWidth: lineWidth,
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
        if let name = name,
            let atom = self.atoms[name] {
            self.atomDisplayerView.atom = atom
            self.atomDisplayerView.animate(shown: true)
        } else {
            graphNodeView.selectedNodeName = nil
            if self.atomDisplayerView.shown {
                self.atomDisplayerView.animate(shown: false)
            }
        }
    }
    
}
