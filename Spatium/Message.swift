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
    
    func chatPartnerId() -> String {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return (toId)!
        } else {
            return (fromId)!
        }
    }
    
}
