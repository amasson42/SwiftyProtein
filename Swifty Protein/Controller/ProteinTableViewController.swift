//
//  ProteinTableViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

let qos                 = DispatchQoS.background.qosClass
let queue               = DispatchQueue.global(qos: qos)

class ProteinTableViewController: UITableViewController {

    var proteinsIDs: [String]       = []
    var proteinsHeaders: [ProteinHeader?] = []
    @IBOutlet var tabProtein: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabProtein.delegate     = self
        tabProtein.dataSource   = self
        tabProtein.rowHeight    = UITableViewAutomaticDimension
        tabProtein.estimatedRowHeight = 40
        loadProteins()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProteins() {
        self.proteinsIDs = ProteinManager.allProteinIDs
        self.proteinsHeaders = []
        for id in self.proteinsIDs {
            self.proteinsHeaders.append(ProteinManager.shared.loadProteinHeader(id: id))
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.proteinsHeaders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProtein", for: indexPath) as! ProteinTableViewCell
        networkCount += 1
        cell.labID.text = self.proteinsIDs[indexPath.row]
        return cell
    }

    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToProtein", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToProtein" {
            guard let vc = segue.destination as? ProteinViewController,
                let row = sender as? Int,
                let proteinHeader = self.proteinsHeaders[row],
                let proteinData = ProteinManager.shared.loadProteinData(header: proteinHeader) else {
                return
            }
            vc.protein = (proteinHeader, proteinData)
        }
    }

}

//  error "popup"
extension ProteinTableViewController {
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let OkAction        = UIAlertAction(title: "OK", style: .default, handler: nil)
//        let DeleteAction    = UIAlertAction(title: "Delete", style: .destructive, handler: handleDelete)
//        let CancelAction    = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancel)
        
        alert.addAction(OkAction)
//        alert.addAction(DeleteAction)
//        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleOK(alertAction: UIAlertAction!) -> Void {
    }
    func handleDelete(alertAction: UIAlertAction!) -> Void {
    }
    func handleCancel(alertAction: UIAlertAction!) {
    }
    
}
