//
//  CustomCell.swift
//  SampleDemo
//
//  Created by Deepak Mitra on 26/09/2017.
//  Copyright © 2017 Deepak Mitra. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    //MARK: - Outlets & Properties
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imvBrand: UIImageView!
    @IBOutlet weak var imvDownLoad: UIImageView!
    var isDwnLd = Bool()

    //MARK: - Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
