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
    
    weak var selectedHeader: ProteinHeader?
    var selectedData: ProteinData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate     = self
        tableView.dataSource   = self
        tableView.rowHeight    = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        self.proteinsHeaders = Array<ProteinHeader?>(repeating: nil, count: ProteinManager.allProteinIDs.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToProtein" {
            guard let vc = segue.destination as? ProteinViewController,
                let proteinHeader = self.selectedHeader,
                let proteinData = self.selectedData else {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellProtein", for: indexPath) as! ProteinTableViewCell
        
        if let header = self.proteinsHeaders[indexPath.row] {
            cell.takeValue(fromProteinHeader: header)
        } else {
            let id = ProteinManager.allProteinIDs[indexPath.row]
            cell.takeValue(fromLoadingId: id)
            ProteinManager.shared.loadProteinHeader(id: id) {
                (header, error) in
                guard let header = header else {
                    if let error = error {
                        DispatchQueue.main.async {
                            cell.takeErrorValue()
                        }
                        print(error)
                    } else {
                        print("no header")
                    }
                    return
                }
                self.proteinsHeaders[indexPath.row] = header
                DispatchQueue.main.async {
                    cell.takeValue(fromProteinHeader: header)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let header = self.proteinsHeaders[indexPath.row] {
            self.selectedHeader = header
            ProteinManager.shared.loadProteinData(header: header) {
                (data, error) in
                guard let data = data else {
                    if let error = error {
                        print(error)
                    } else {
                        print("no data")
                    }
                    return
                }
                self.selectedData = data
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueToProtein", sender: tableView)
                }
            }
        }
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
