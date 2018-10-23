//
//  Album.swift
//  Minerva
//
//  Created by Tristan Griffin on 10/21/18.
//  Copyright © 2018 Tristan Griffin. All rights reserved.
//

import UIKit

class Album: NSObject, NSCoding {
    
    //Public Properties
    var name: String
    var photo: UIImage?
    var isFavorite: Bool
    
    //Archive Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("albums")
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let isFavorite = "isFavorite"
    }
    
    init?(name: String, photo: UIImage?, isFavorite: Bool) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.photo = photo
        self.isFavorite = isFavorite
    }
    
    //MARK: Encoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(isFavorite, forKey: PropertyKey.isFavorite)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodedName = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            fatalError("Unable to decode the name of album object")
            return nil
        }
        let decodedPhoto = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let decodedIsFavorite = aDecoder.decodeObject(forKey: PropertyKey.isFavorite) as? Bool ?? false

        self.init(name: decodedName, photo: decodedPhoto, isFavorite: decodedIsFavorite)
    }
    
    
}
