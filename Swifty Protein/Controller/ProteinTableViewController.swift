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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        searchBar.barTintColor = UIColor(red: 253/255, green: 170/255, blue: 41/255, alpha: 1.0) //253 170 41 jaune // 121 144 155 gris
        let backgroundImage = UIImage(named: "background.jpg")
        let imageView = UIImageView(image: backgroundImage)
        imageView.alpha = 0.2
        imageView.contentMode = .scaleAspectFit
        tableView.backgroundView = imageView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
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
        cell.idLabel.textColor      = .black
//        cell.nameLabel.textColor    = .white
//        cell.formulaLabel.textColor = .white
        switch self.proteinsHeaders[index] {
        case .unopen:
            cell.takeValue(fromLoadingId: id)
            self.proteinsHeaders[index] = .downloading
            ProteinManager.shared.loadProteinHeader(id: id) {
                (header, error) in
                guard let header = header else {
                    DispatchQueue.main.async {
                        self.proteinsHeaders[index] = .error
                        cell.idLabel.textColor      = .red
                        cell.takeErrorValue(withId: id)
                        self.alert(title: "Ligand \(id)", message: "Loading error", id: id)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.proteinsHeaders[index] = .downloaded(header: header)
                    cell.takeValue(fromProteinHeader: header)
                    guard tableView.cellForRow(at: indexPath) != nil else { return }
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        case .downloading:
            cell.takeValue(fromLoadingId: ProteinManager.allProteinIDs[index])
        case .downloaded(let header):
            cell.takeValue(fromProteinHeader: header)
        case .error:
            cell.idLabel.textColor      = .red
            cell.takeErrorValue(withId: id)
        }
        
        cell.backgroundColor    = .clear
        cell.backgroundColor    = UIColor(white: 1, alpha: 0.1)
        
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
                        self.alert(title: "Ligand \(header.id)", message: "Can't download data", id: header.id)
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
    
    func alert(title: String, message: String, id: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
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
