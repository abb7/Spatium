//
//  Extentensions.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit

let imageCache: NSCache<NSString, UIImage> = NSCache()
extension UIImageView {
    
    ////////////////////////////////////////////////////////////////
    //to load the image and save them in cache
    func loadImageUsingCachWithUrlString(_ UrlString: String){
        
        //to remove flickering
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: UrlString as NSString ){
            //object(forKey: UrlString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: UrlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            //download hit an error so lets retrun out
            if error != nil{
                print(error)
                return
                
            }
            
            
            DispatchQueue.main.async(execute: { () -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: UrlString as NSString)
                    self.image = downloadedImage
                    
                }
            })
            
        }).resume()
    }
}
