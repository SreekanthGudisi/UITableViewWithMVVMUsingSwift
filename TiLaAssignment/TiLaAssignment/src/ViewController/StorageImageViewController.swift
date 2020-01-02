//
//  StorageImageViewController.swift
//  TiLaAssignment
//
//  Created by Gudisi, Sreekanth on 15/12/19.
//  Copyright © 2019 Gudisi, Sreekanth. All rights reserved.
//

import UIKit

class StorageImageViewController {

    // Class StroreImages
    static func storeImage(urlstring: String, img: UIImage) {
        
        let path = NSTemporaryDirectory().appending(UUID().uuidString)
        let url = URL(fileURLWithPath: path)
        let data = img.jpegData(compressionQuality: 0.7)
        try? data?.write(to: url)
        var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String : String]
        if dict == nil {
            dict = [ String: String]()
        }
        dict![urlstring] = path
        UserDefaults.standard.set(dict, forKey: "ImageCache")
    }
}
