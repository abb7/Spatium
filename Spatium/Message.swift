//
//  Message.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId : String?
    var toId : String?
    var timeStamp: NSNumber?
    var text: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?
    
    func chatPartnerId() -> String {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return (toId)!
        } else {
            return (fromId)!
        }
    }
    
    //to prevent the app from crashing every time we interduce a new property
    init(dictionary:  [String: AnyObject]) {
        super.init()
        fromId = dictionary ["fromId"] as? String
        toId = dictionary ["toId"] as? String
        timeStamp = dictionary ["timeStamp"] as? NSNumber
        text = dictionary ["text"] as? String
        imageUrl = dictionary ["imageUrl"] as? String
        imageWidth = dictionary ["imageWidth"] as? NSNumber
        imageHeight = dictionary ["imageHeight"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
        
    }
    
}
