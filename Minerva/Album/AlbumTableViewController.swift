//
//  AlbumTableViewController.swift
//  Minerva
//
//  Created by Tristan Griffin on 10/21/18.
//  Copyright © 2018 Tristan Griffin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class AlbumTableViewController: UITableViewController {

    //MARK: Properties
    var albums = [Album]()
    fileprivate let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedData = loadAlbums() {
            albums += savedData
        } else {
            loadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifer = "AlbumTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath) as? AlbumTableViewCell else {
            fatalError("Dequeue cell is not of instance AlbumTableViewCell")
        }

        //Fetches appropriate album for the appropriate cell
        let album = albums[indexPath.row]
                
        cell.albumNameLabel.text = album.name
        cell.albumThumbnailImageView.image = album.photo

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            albums.remove(at: indexPath.row)
            saveAlbums()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowDetail":
            guard let albumPhotosViewController = segue.destination as? AlbumPhotosViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedAlbumCell = sender as? AlbumTableViewCell else {
                fatalError("Unexpected Sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedAlbumCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedAlbum = albums[indexPath.row]
            albumPhotosViewController.album = selectedAlbum.name
        
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }

    }
    
    //MARK: Actions
    @IBAction func addAlbum(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create Album", message: "Enter Name:", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: { (textField: UITextField!) in
            textField.placeholder = "Album name"
            textField.isSecureTextEntry = false
        })
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            let newAlbumName = alert.textFields![0].text ?? ""
            guard let album = Album.init(name: newAlbumName, photo: UIImage(named: "defaultImage"), isFavorite: false) else {
                fatalError("Cannot create new album. Attempted to create: \(newAlbumName)")
            }
            self.albums.append(album)
            self.saveAlbums()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Private functinons
    private func loadData() {
        db.collection("users").document((Auth.auth().currentUser?.uid)!)
            .collection("public").getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        guard let album = Album.init(name: document.documentID, photo: UIImage(named: "defaultImage"), isFavorite: document.get("isFavorite") as? Bool ?? false) else {
                            print("Cannot create album: \(document.documentID)")
                            return
                        }
                        self.albums.append(album)
                    }
                    self.saveAlbums()
                    self.tableView.reloadData()
                }
        }
    }
    
    private func saveAlbums() {
        _ = NSKeyedArchiver.archiveRootObject(albums, toFile: Album.ArchiveURL.path)
    }
    
    private func loadAlbums() -> [Album]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Album.ArchiveURL.path) as? [Album]
    }

}
