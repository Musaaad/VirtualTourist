//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Musaad on 12/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func set (image: UIImage) {
        self.image = image.pngData()
    }
    
    func getImage() -> UIImage? {
        return (image == nil) ? nil : UIImage(data: image!)
    }
    
    
}
