//
//  MovieDetailViewController.swift
//  MyMovies
//
//  Created by Luke Seo on 4/29/19.
//  Copyright © 2019 Luke Seo. All rights reserved.
//

import UIKit
import Firebase

class MovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movieId : Int = -1
    var handle: AuthStateDidChangeListenerHandle!
    var currentUser: User? = Auth.auth().currentUser
    var tmdbAPIKey = "70886ff1eb786a6e0c8667f29db936b3"
    var docRef: DocumentReference!
    var favoriteRef: DocumentReference!
    var reviewData : [String] = []
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionView: UITextView!
    @IBOutlet weak var reviewTextInput: UITextField!
    @IBOutlet weak var reviewTable: UITableView!
    @IBOutlet weak var submitReviewButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        reviewTable.delegate = self
        reviewTable.dataSource = self
        
        // Check google authentication
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.currentUser = user
        }
        
        
        // Set firestore reference
        let movieIdString = String(movieId)
        let userId = currentUser?.uid
        if (userId != nil && userId != "") {
            docRef = Firestore.firestore().document("\(movieIdString)Reviews/\(userId ?? "")")
            favoriteRef = Firestore.firestore().document("\(userId ?? "")/\(movieIdString)")
        } else {
            submitReviewButton.isHidden = true
            favoriteButton.isHidden = true
        }
        
        // set review rows
        let db = Firestore.firestore()
        db.collection("\(movieIdString)Reviews").getDocuments() { (querySnapshot, err) in
            if let err = err  {
                print("Error getting documents \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.reviewData.append(document.data()["review"] as! String)
                    DispatchQueue.main.async() {
                        self.reviewTable.reloadData()
                    }
                }
            }
        }
 
        
        // Download and set image
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(tmdbAPIKey)&language=en-US")
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleResponse)
        dataTask.resume()
        
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
                    print(jsonDict)
                    DispatchQueue.main.async {
                        self.movieTitleLabel.text = (jsonDict["title"] as! String)
                        self.movieDescriptionView.text = (jsonDict["overview"] as! String)
                        let img = jsonDict["backdrop_path"]
                        let url = URL(string: "https://image.tmdb.org/t/p/w300\(img ?? "" as AnyObject)")!
                        self.downloadImage(from: url)
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
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                self.movieImage.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        guard let reviewText = reviewTextInput.text, !reviewText.isEmpty else { return }
        guard currentUser != nil, currentUser?.uid != nil, currentUser?.uid != "" else { return }
        let dataToSave: [String : Any] = ["review" : reviewText, "uid" : currentUser?.uid ?? ""]
        docRef.setData(dataToSave) { (error) in
            if let error = error {
                print("There was an error : \(error.localizedDescription)")
            } else  {
                print("Review data saved!")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        cell.textLabel?.text = reviewData[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
    
    @IBAction func favoriteButtonClicked(_ sender: UIButton) {
        guard currentUser != nil, currentUser?.uid != nil, currentUser?.uid != "" else { return }
        let movieIdString = String(movieId)
        let dataToSave: [String : Any] = ["moveid" : movieIdString, "uid" : currentUser?.uid ?? "", "title" : movieTitleLabel.text ?? ""]
        favoriteRef.setData(dataToSave) { (error) in
            if let error = error {
                print("There was an error : \(error.localizedDescription)")
            } else  {
                print("Favorite movie data saved!")
            }
        }
    }
}
