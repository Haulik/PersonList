//
//  TableViewController.swift
//  FarmersMarked
//
//  Created by Thomas Haulik Barchager on 10/10/2019.
//  Copyright © 2019 Haulik. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var postData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set the firebase reference
        ref = Database.database().reference()
        
        // Retrieve the posts and listen for changes
        databaseHandle = ref?.child("Posts").observe(.childAdded, with: { (DataSnapshot) in
            
            // Code to execute when a child is added under "Posts"
            // Take the value from the snapshot and added it to the postData array
            
            // Try to convert the value of the data to a string
            let post = DataSnapshot.value as? String
            
            if let actualPost = post{
                
            // Append the data to our postData array
                self.postData.append(actualPost)
            
            // Reload the tableview
                self.tableView.reloadData()
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell")
        cell?.textLabel?.text = postData[indexPath.row]
        
        return cell!
    }
}
