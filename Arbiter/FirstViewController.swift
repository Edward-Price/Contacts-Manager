//
//  FirstViewController.swift
//  Contacts
//
//  Created by Edward Price on 12/11/2017.
//  Copyright © 2017 Edward Price. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contacts = [CNContact]()
    var contactStore = CNContactStore()
    var letters = [Character]()
    var contactsSorted = [String : [CNContact]]()
    var allContacts = [[CNContact]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.tableView.isHidden = false
            DispatchQueue.global(qos: .background).async {
                let allContacts = self.getContacts()
                self.contacts = allContacts
                self.sortContacts(contacts: allContacts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        case .notDetermined:
            showOpenSettingsBtn()
            contactStore.requestAccess(for: .contacts){success, err in
                if success{
                    DispatchQueue.global(qos: .background).async {
                        let allContacts = self.getContacts()
                        self.contacts = allContacts
                        self.sortContacts(contacts: allContacts)
                        DispatchQueue.main.async {
                            self.tableView.isHidden = false
                            self.view.bringSubview(toFront: self.tableView)
                            self.tableView.reloadData()
                        }
                    }
                }
                guard err == nil && success else{
                    return
                }
            }
        case .denied:
            showOpenSettingsBtn()
            
        default:
            print("Not handled")
        }
        
    }
    
    // MARK: - open settings to allow contact access
    
    func showOpenSettingsBtn(){
        self.tableView.isHidden = true
        let openContactsBTN = UIButton(frame: CGRect(x: (self.view.frame.size.width - 250) / 2, y: ((self.view.frame.size.height - 50) / 2) + 80, width: 250, height: 50))
        openContactsBTN.backgroundColor = UIColor(red: 0.1647, green: 0.8275, blue: 0, alpha: 1.0)
        openContactsBTN.setTitle("Import Contacts", for: .normal)
        openContactsBTN.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        let image = UIImage(named: "notFound.jpg")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: (self.view.frame.size.width - 259) / 2, y: ((self.view.frame.size.height - 203) / 2) - 80, width: 259, height: 203)

        self.view.addSubview(openContactsBTN)
        self.view.addSubview(imageView)
    }
    
    @objc func openSettings(sender: UIButton!) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - fetch all contacts

    func getContacts() -> [CNContact] {
        
        let contactStore : CNContactStore = CNContactStore()
        var contacts : [CNContact] = [CNContact]()
        let fetchRequest : CNContactFetchRequest = CNContactFetchRequest(keysToFetch:[CNContactVCardSerialization.descriptorForRequiredKeys()])
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        do{
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                contact, cursor in
                contacts.append(contact)})
        } catch {
            print(error.localizedDescription)
        }
        return contacts
    }
    
    // MARK: - set contacts to alphabetical groups
    func sortContacts(contacts: [CNContact]){
        
        // Build letters array first:
        letters = contacts.map { (name) -> Character in
            if name.familyName != "" {
                return name.familyName[name.familyName.startIndex]
            }
            else if name.givenName != ""{
                return name.givenName[name.givenName.startIndex]
            }
            else if name.organizationName != ""{
                return name.organizationName[name.organizationName.startIndex]
            }
            else{
                return "A"
            }
        }
        
        letters = letters.sorted()
        letters = letters.reduce([], { (list, name) -> [Character] in
            if !list.contains(name) {
                return list + [name]
            }
            return list
        })
        
        
        // Build contacts array:
        for entry in contacts {
            
            if entry.familyName != "" {
                if contactsSorted[String(entry.familyName[entry.familyName.startIndex])] == nil {
                    contactsSorted[String(entry.familyName[entry.familyName.startIndex])] = [CNContact]()
                }
                contactsSorted[String(entry.familyName[entry.familyName.startIndex])]!.append(entry)
            }
            else if entry.givenName != ""{
                if contactsSorted[String(entry.givenName[entry.givenName.startIndex])] == nil {
                    contactsSorted[String(entry.givenName[entry.givenName.startIndex])] = [CNContact]()
                }
                contactsSorted[String(entry.givenName[entry.givenName.startIndex])]!.append(entry)
            }
            else if entry.organizationName != ""{
                if contactsSorted[String(entry.organizationName[entry.organizationName.startIndex])] == nil {
                    contactsSorted[String(entry.organizationName[entry.organizationName.startIndex])] = [CNContact]()
                }
                contactsSorted[String(entry.organizationName[entry.organizationName.startIndex])]!.append(entry)
            }
            else{
                print("no name")
            }

        }

        for (letter, list) in contactsSorted {
            contactsSorted[letter] = list
        }
        
        allContacts = contactsSorted.keys.sorted().map { contactsSorted[$0]! }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(letters[section])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContacts[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let contacts = allContacts[indexPath.section]
        let contactDetails = contacts[indexPath.row]
        
        cell.textLabel!.text = "\(contactDetails.givenName) \(contactDetails.familyName)"
        if contactDetails.phoneNumbers != [] {
            cell.detailTextLabel?.text = "\(contactDetails.phoneNumbers[0].value.stringValue)"
        }
        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        cell.imageView?.layer.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        cell.imageView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        cell.imageView?.image = UIImage(named: "profile-default")!.alpha(0.4)
        cell.imageView?.backgroundColor = .random()
        cell.imageView?.layer.cornerRadius = 32
        
        return cell
    }
    
    var name = String()
    var number = String()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContactSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                let destViewController = segue.destination as! EditViewController
                destViewController.hidesBottomBarWhenPushed = true
                name = (self.tableView.cellForRow(at: indexPath)?.textLabel?.text)!
                print(name)
                //destViewController.nameLabel.text = (self.tableView.cellForRow(at: indexPath)?.textLabel?.text)!
            }
        }
    }
    

}

