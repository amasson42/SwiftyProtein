//
//  ProteinTableViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit

class ProteinTableViewController: UIViewController {
    
    enum CellState {
        case unopen
        case downloading
        case downloaded(header: ProteinHeader)
        case error
    }
    var proteinsHeaders: [CellState] = []
    var filteredIndexes: [Int] = []
    
    weak var selectedHeader: ProteinHeader?
    var selectedData: ProteinData?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate     = self
        tableView.delegate     = self
        tableView.dataSource   = self
        tableView.rowHeight    = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        self.proteinsHeaders = Array<CellState>(repeating: .unopen, count: ProteinManager.allProteinIDs.count)
        self.filteredIndexes = self.proteinsHeaders.indices.map({$0})
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

extension ProteinTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredIndexes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellProtein", for: indexPath) as! ProteinTableViewCell
        
        let index = self.filteredIndexes[indexPath.row]
        let id = ProteinManager.allProteinIDs[index]
        switch self.proteinsHeaders[index] {
        case .unopen:
            cell.takeValue(fromLoadingId: id)
            self.proteinsHeaders[index] = .downloading
            ProteinManager.shared.loadProteinHeader(id: id) {
                (header, error) in
                guard let header = header else {
                    DispatchQueue.main.async {
                        self.proteinsHeaders[index] = .error
                        cell.takeErrorValue(withId: id)
                        self.alert(title: "Ligand \(id)", message: "Loading error")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.proteinsHeaders[index] = .downloaded(header: header)
                    cell.takeValue(fromProteinHeader: header)
                }
            }
        case .downloading:
            cell.takeValue(fromLoadingId: ProteinManager.allProteinIDs[index])
        case .downloaded(let header):
            cell.takeValue(fromProteinHeader: header)
        case .error:
            cell.takeErrorValue(withId: id)
        }
        
        return cell
    }
    
}

extension ProteinTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = self.filteredIndexes[indexPath.row]
        if case .downloaded(let header) = self.proteinsHeaders[index] {
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

extension ProteinTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        defer {
            self.tableView.reloadData()
        }
        guard let text = searchBar.text,
            !text.isEmpty else {
                self.filteredIndexes = self.proteinsHeaders.indices.map({$0})
                return
        }
        self.filteredIndexes = ProteinManager.allProteinIDs.enumerated()
            .filter({$0.element.range(of: text, options: .caseInsensitive) != nil})
            .map({$0.offset})
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
