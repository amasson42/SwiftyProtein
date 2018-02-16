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
var networkCount: Int   = 0

class ProteinTableViewController: UITableViewController {

    var proteins: [Protein]     = []
    var parserGetIt: Bool       = false
    var parserElement:String    = ""
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proteins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProtein", for: indexPath) as! ProteinTableViewCell
        networkCount += 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        cell.labID.text  = proteins[indexPath.row].ID
        return cell
    }

    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToProtein", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToProtein" {
            if let vc = segue.destination as? ProteinViewController {
                let row = sender as! Int
                vc.title = proteins[row].ID
            }
        }
    }

}

//  loading and parsing proteins head data
extension ProteinTableViewController {
    
    func loadProteins() {
        proteins = []
        let textUrl = URL(string: "https://projects.intra.42.fr/uploads/document/document/312/ligands.txt")
        do {
            let data = try String(contentsOf: textUrl!, encoding: .utf8)
            let myStrings = data.components(separatedBy: .newlines)
            for i in 0..<myStrings.count {
                if myStrings[i] != "" {
                    proteins.append(Protein(ID: String(describing: myStrings[i])))
//                    asyncLoad(row: i)
                }
            }
        } catch {
            alert(title: "Loading error!", message: "Unable to reach \(textUrl!)")
        }
    }
    
    func asyncLoad(row: Int) {
        
        queue.async {

//            DispatchQueue.main.async {
//                cell.activityInd.startAnimating()
//            }
            
            let parser = XMLParser(contentsOf: self.proteins[row].getURLentete())
            parser?.delegate = self
            if (parser?.parse())! {
                DispatchQueue.main.async {
                 
//                    cell.activityInd.stopAnimating()
                    networkCount -= 1
                    if networkCount == 0 {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alert(title: "Error", message: "Cannot access RCSB ligand data for " + self.proteins[row].ID)
                    print("error \(row)")
//                    cell.activityInd.stopAnimating()
                    networkCount -= 1
                    if networkCount == 0 {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }

        }
    }

}

extension ProteinTableViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName == "PDBx:name" {
            parserElement = "name"
            parserGetIt = true
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if parserGetIt {
            print("\(parserElement) \(string)")
            parserGetIt = false
        }
    }
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        print("Did end element: \(elementName)")
//    }
//    func parserDidEndDocument(_ parser: XMLParser) {
//        print("Completed parsing document")
//    }
    
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
