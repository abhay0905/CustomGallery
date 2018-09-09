//
//  PhotoCollectionViewCell.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 03/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var vwHolder: UIView!
    @IBOutlet weak var imgPhoto: UIImageView!
    var representedAssetIdentifier : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
