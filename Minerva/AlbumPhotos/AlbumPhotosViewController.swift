//
//  AlbumPhotosViewController.swift
//  Minerva
//
//  Created by Tristan Griffin on 10/21/18.
//  Copyright © 2018 Tristan Griffin. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore

class AlbumPhotosViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Private Properties
    fileprivate let db = Firestore.firestore()
    fileprivate let storage = Storage.storage()
    fileprivate let reuseIdentifier = "AlbumPhotosCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    private var images: [Any] = []
    
    //MARK: Public Properties
    var album: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        //Load Photo data
        loadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AlbumPhotosCollectionViewCell else {
            fatalError("Dequeue cell is not of instance AlbumPhotosCollectionViewCell")
        }
    
        // Configure the cell
        let image = images[indexPath.row]
        //If the image is from firebase firestore -> download
        if ((image as? String) != nil) {
            let storageRef = storage.reference(forURL: image as! String)
            storageRef.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let error = error {
                    fatalError("Error Downloading Image from ref: \(storageRef) => \(error)")
                } else {
                    cell.imagePhotoView.image = UIImage(data: data!)
                }
            }
        //The was added to album from the gallery
        } else {
            cell.imagePhotoView.image = image as? UIImage
        }
 
        return cell
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //The info dictionary may contain multiple representations of the image. You want to use the original
        guard let selectedImage = info[(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //Set the photo
        print("The photo is identified through: \(String(describing: selectedImage.accessibilityIdentifier))")
        self.images.append(selectedImage)
        collectionView.reloadData()
        
        //Dismiss Picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func addPhotoToAlbum(_ sender: UIBarButtonItem) {
        //UIImagePicker is a view controller that lets users pick media from photo library
        let imagePickerController = UIImagePickerController()
        
        //Only allow photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        //Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Functions
    private func loadData() {
        db.collection("users").document((Auth.auth().currentUser?.uid)!)
            .collection("public").document(album!)
            .collection("images").getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.images.append(document.get("ref") as! String)
                    }
                    self.collectionView.reloadData()
                }
        }
    }

}

// MARK: UICollectionViewDelegateFlowLayout
extension AlbumPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
