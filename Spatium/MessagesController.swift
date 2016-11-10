//
//  ViewController.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessagesController: UITableViewController {
    
    private let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MessagesController.handleLogout))
        
        checkIfUserLoggedIn()
        
        let image = UIImage(named: "new-message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(MessagesController.handleNewMessage))
        
        checkIfUserLoggedIn()
        
        //tableView.register(UserCell.self, forHeaderFooterViewReuseIdentifier: cellId)
        
        observeMessages()
    }
    
    //An Array of type message that will keep a Number of the messages sent to the user
    var messages = [Message]()
    
    
    ////////////////////////////////////////////////////////////////
    //to keep watching new messages and update the user with it
    func observeMessages(){
        let ref = FIRDatabase.database().reference().child("Messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                //this will crash because of background thread, so let call this on dispatch_async main thred
                //self.tableView.reloadData()
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
            
            }, withCancel: nil)
    }
    
    ////////////////////////////////////////////////////////////////
    //to state the number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    ////////////////////////////////////////////////////////////////
    //to set up the data inside each Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        let message = messages[indexPath.row]
        if let toId = message.toId {
            let ref  = FIRDatabase.database().reference().child("Users").child(toId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    cell.textLabel?.text = dictionary["name"]as? String
                }
                
                print(snapshot)
                }, withCancel: nil)
        }
        
        //cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    
    ////////////////////////////////////////////////////////////////
    //to check if the user is logged in
    func checkIfUserLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(MessagesController.handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetUpNavBarTitle()
        }
    }
    
    ////////////////////////////////////////////////////////////////
    //to set the user name on the navigation bar of the messages view
    func fetchUserAndSetUpNavBarTitle(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid  else {
            //if uid = nil
            return
        }
        FIRDatabase.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            //print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user)
            }
            
            }, withCancel: nil)
        
    }
    
    
    ////////////////////////////////////////////////////////////////
    //to set up the navigation bar title with both the image and the name
    func setupNavBarWithUser(_ user: User){
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageURL = user.profileImageURL {
            profileImageView.loadImageUsingCachWithUrlString(profileImageURL)
        }
        
        containerView.addSubview(profileImageView)
        //need x,y,height, and width
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        //need x,t,height,width
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessagesController.showChatController)))
        
    }
    
    ////////////////////////////////////////////////////////////////
    //to display the chatLogController for the user
    func showChatControllerForUser (user: User){
        let chatlogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatlogController.user = user
        navigationController?.pushViewController(chatlogController, animated: true)
    }
    
    ////////////////////////////////////////////////////////////////
    //to logout and display the login view
    func handleLogout(){
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesContoller = self    //
        present(loginController, animated: true, completion: nil)
        
    }
    
    ////////////////////////////////////////////////////////////////
    //to make the newMessage view appear
    func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
}



