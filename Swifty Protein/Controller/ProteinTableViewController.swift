//
//  ProteinTableViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class ProteinTableViewController: UITableViewController {
    
    var proteinsHeaders: [ProteinHeader?] = []
    var proteinData: ProteinData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProteinManager.shared.delegate = self
        tableView.delegate     = self
        tableView.dataSource   = self
        tableView.rowHeight    = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        self.loadProteins()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProteins() {
        let proteinsIDs = ProteinManager.allProteinIDs
        self.proteinsHeaders = Array<ProteinHeader?>(repeating: nil, count: proteinsIDs.count)
        for id in proteinsIDs {
            ProteinManager.shared.loadProteinHeader(id: id)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToProtein" {
            guard let vc = segue.destination as? ProteinViewController,
                let row = sender as? Int,
                let proteinHeader = self.proteinsHeaders[row],
                let proteinData = self.proteinData else {
                    return
            }
            vc.protein = (proteinHeader, proteinData)
        }
    }
    
}

extension ProteinTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProteinManager.allProteinIDs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProtein", for: indexPath) as! ProteinTableViewCell
        
        // TODO: setup cell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let header = self.proteinsHeaders[indexPath.row] {
            ProteinManager.shared.loadProteinData(header: header)
        }
    }
    
}

extension ProteinTableViewController: ProteinManagerDelegate {
    
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingHeader header: ProteinHeader) {
        if let index = ProteinManager.allProteinIDs.index(of: header.ID) {
            self.proteinsHeaders[index] = header
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func proteinManager(_ proteinManager: ProteinManager, finishedLoadingData data: ProteinData) {
        self.proteinData = data
        self.performSegue(withIdentifier: "segueToProtein", sender: self)
    }
    
    func proteinManager(_ proteinManager: ProteinManager, error: ProteinManager.LoadingError, loading id: String) {
        print("error: \(error) while loading \(id)")
        self.alert(title: "Error", message: "can't load \(id)")
    }
    
}

//  error "popup"
extension ProteinTableViewController {
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OkAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleOK(alertAction: UIAlertAction!) -> Void {
    }
    
    func handleDelete(alertAction: UIAlertAction!) -> Void {
    }
    
    func handleCancel(alertAction: UIAlertAction!) {
    }
    
}
