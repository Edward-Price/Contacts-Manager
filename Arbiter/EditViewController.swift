//
//  EditViewController.swift
//  Arbiter
//
//  Created by Edward Price on 03/12/2017.
//  Copyright © 2017 Edward Price. All rights reserved.
//

import UIKit
import Contacts

class EditViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    var contactDetails = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //nameLabel.text = contactDetails
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
