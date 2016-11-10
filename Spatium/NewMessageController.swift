//
//  NewMessageController.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewMessageController: UITableViewController {
    
    private let cellId = "cellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewMessageController.handleCancel))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)  //to deploy the class "UserClass"
        
        fetchUser()
    }
    
    ////////////////////////////////////////////////////////////////
    //get users from the database into the users array and dispatch async
    func fetchUser(){
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) -> Void in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.id = snapshot.key
                
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                //so we can use the following statment:-
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancel: nil)
    }
    
    ////////////////////////////////////////////////////////////////
    //to cancel the new message and go back to messages view
    func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////////////////
    //return the number of users from the database
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    ////////////////////////////////////////////////////////////////
    //to set the user information in each row and pass the url to get the profile image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageURL = user.profileImageURL{
            cell.profileImageView.loadImageUsingCachWithUrlString(profileImageURL)
        }
        
        return cell
    }
    ////////////////////////////////////////////////////////////////
    //to set the height for each row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    ////////////////////////////////////////
    //to choose the user out of the newMessageController list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser( user: user)
        }
    }
}

