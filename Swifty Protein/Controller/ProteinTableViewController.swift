//
//  ProteinTableViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class ProteinTableViewController: UITableViewController {
    
    enum CellState {
        case unopen
        case downloading
        case downloaded(header: ProteinHeader)
        case error
    }
    var proteinsHeaders: [CellState] = []
    
    weak var selectedHeader: ProteinHeader?
    var selectedData: ProteinData?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate     = self
        tableView.dataSource   = self
        tableView.rowHeight    = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        self.proteinsHeaders = Array<CellState>(repeating: .unopen, count: ProteinManager.allProteinIDs.count)
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
        
        switch self.proteinsHeaders[indexPath.row] {
        case .unopen:
            let id = ProteinManager.allProteinIDs[indexPath.row]
            cell.takeValue(fromLoadingId: id)
            self.proteinsHeaders[indexPath.row] = .downloading
            ProteinManager.shared.loadProteinHeader(id: id) {
                (header, error) in
                guard let header = header else {
                    DispatchQueue.main.async {
                        self.proteinsHeaders[indexPath.row] = .error
                        cell.takeErrorValue()
                        self.alert(title: "Ligand \(id)", message: "Loading error")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.proteinsHeaders[indexPath.row] = .downloaded(header: header)
                    cell.takeValue(fromProteinHeader: header)
                }
            }
        case .downloading:
            cell.takeValue(fromLoadingId: ProteinManager.allProteinIDs[indexPath.row])
        case .downloaded(let header):
            cell.takeValue(fromProteinHeader: header)
        case .error:
            cell.takeErrorValue()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .downloaded(let header) = self.proteinsHeaders[indexPath.row] {
            self.selectedHeader = header
            ProteinManager.shared.loadProteinData(header: header) {
                (data, error) in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.alert(title: "Ligand \(header.id)", message: "Can't download data")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.selectedData = data
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
