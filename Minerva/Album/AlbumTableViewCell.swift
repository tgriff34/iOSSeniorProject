//
//  AlbumTableViewCell.swift
//  Minerva
//
//  Created by Tristan Griffin on 10/21/18.
//  Copyright © 2018 Tristan Griffin. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumThumbnailImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func albumFavoriteButton(_ sender: UIButton) {
        //TODO
    }
    
    @IBAction func albumDeleteButton(_ sender: UIButton) {
        //TODO
    }
}
