//
//  UserCell.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

////////////////////////////////////////////////////////////////
//NEW CLASS WITH USER CELL PROPERTIES OF TYPE UITABLEVIEWCELL
////////////////////////////////////////////////////////////////
class UserCell: UITableViewCell {
    
    ////////////////////////////////////////////////////////////////
    //whenever we set message of this userCell it will apply this commands
    var message: Message?{
        didSet{
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm a"
                timeLabel.text = dateFormater.string(from: timeStampDate as Date)
            }
            
            
        }
        
    }
    
    private func  setupNameAndProfileImage() {
        
        
        if let id = message?.chatPartnerId(){
            let ref  = FIRDatabase.database().reference().child("Users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageURL = dictionary["profileImageURL"] as? String{
                        self.profileImageView.loadImageUsingCachWithUrlString(profileImageURL)
                    }
                }
                
            print(snapshot)
            }, withCancel: nil)
        }
    }

    ////////////////////////////////////////////////////////////////
    //to modify the text and detail text of the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }

    ////////////////////////////////////////////////////////////////
    //set up Profile Image View
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "winter_is_coming")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill


        return imageView
    }()
    
    ////////////////////////////////////////////////////////////////
    //set up time label
    let timeLabel : UILabel = {
       let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    ////////////////////////////////////////////////////////////////
    //to modify the CellStyle and add the profileImageView into the cell
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        //need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
