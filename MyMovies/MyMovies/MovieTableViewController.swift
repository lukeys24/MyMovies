//
//  MovieTableViewController.swift
//  MyMovies
//
//  Created by Luke Seo on 4/28/19.
//  Copyright © 2019 Luke Seo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MovieTableViewController: UITableViewController {
    var images: [(UIImage,Int)] = []
    var handle: AuthStateDidChangeListenerHandle!
    var currentUser: User? = Auth.auth().currentUser
    var tmdbAPIKey = "70886ff1eb786a6e0c8667f29db936b3"
    var selectedRowId : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(MovieViewCell.self, forCellReuseIdentifier: "MovieViewCell")
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.currentUser = user
        }
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(tmdbAPIKey)&language=en-US&page=1")
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleResponse)
        dataTask.resume()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func handleResponse (data: Data?, response: URLResponse?, error: Error?) {
        if let err = error {
            print("error: \(err.localizedDescription)")
        } else {
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if statusCode != 200 {
                let msg = HTTPURLResponse.localizedString(forStatusCode:
                    statusCode)
                print("HTTP \(statusCode) error: \(msg)")
            } else {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!) {
                    let jsonDict = jsonObj as! [String: Any]
                    let movies = jsonDict["results"] as! [[String: AnyObject]]

                    // Iterate through all movies and add to list
                    for movie in movies {
                        let img = movie["poster_path"]
                        let url = URL(string: "https://image.tmdb.org/t/p/w342\(img ?? "" as AnyObject)")!
                        downloadImage(from: url, movieId: movie["id"] as! Int)
                    }
                } else {
                    print("error: invalid JSON data")
                }
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, movieId: Int) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            /*
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            print(data)
            */
            self.images.append(((UIImage(data: data) ?? nil)!, movieId))
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return images.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieViewCell") as! MovieViewCell
        cell.mainImageView.image = images[indexPath.row].0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRowId = images[indexPath.row].1 // retain for prepareForSegue
        performSegue(withIdentifier: "showMovieDetail", sender: nil)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func profileClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProfile", sender: nil)
    }
    
    @IBAction func signOutClicked(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "showLogin", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMovieDetail") {
            let secondVC = segue.destination as! MovieDetailViewController
            secondVC.movieId = selectedRowId
        }
    }
}
