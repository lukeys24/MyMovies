//
//  ProfileViewController.swift
//  MyMovies
//
//  Created by Luke Seo on 4/29/19.
//  Copyright © 2019 Luke Seo. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var favoriteTable: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle!
    var currentUser: User? = Auth.auth().currentUser
    var tmdbAPIKey = "70886ff1eb786a6e0c8667f29db936b3"
    var favoriteData: [(String, String)] = []
    var selectedRowId : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set datasource and delegate for tableview
        favoriteTable.delegate = self
        favoriteTable.dataSource = self
        
        // Check google authentication
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.currentUser = user
        }
        
        // Set label at the top
        let userId = currentUser?.uid
        if (userId != nil && userId != "") {
            userLabel.text = "Favorite Movies for \(currentUser?.email ?? "")"
        } else {
            userLabel.text = "No Favorite Movies to Show, please login."
        }
        
        // set favorite rows
        let db = Firestore.firestore()
        db.collection("\(userId ?? "")").getDocuments() { (querySnapshot, err) in
            if let err = err  {
                print("Error getting documents \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.favoriteData.append((document.data()["title"] as! String, document.data()["moveid"] as! String))
                    DispatchQueue.main.async() {
                        self.favoriteTable.reloadData()
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        cell.textLabel?.text = favoriteData[indexPath.row].0
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRowId = Int(favoriteData[indexPath.row].1)! // retain for prepareForSegue
        performSegue(withIdentifier: "fromProfileToDescription", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromProfileToDescription") {
            let secondVC = segue.destination as! MovieDetailViewController
            secondVC.movieId = selectedRowId
        }
    }
}
