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
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    //An Array of type message that will keep a Number of the messages sent to the user
    var messages = [Message]()
    
    var messagesDictionary = [String: Message]()
    
    var timer: Timer?
    
    
    func observeUserMessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
     let ref = FIRDatabase.database().reference().child("User-Messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in

            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("User-Messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let  messageId = snapshot.key
                //to orgnize our code we took part of the code and set it up in a private function
                self.fetchMessageWithMessageId(messageId: messageId)
                
                }, withCancel: nil)
            return
            }, withCancel: nil)
    }
    
    private func  fetchMessageWithMessageId(messageId: String) {
        let messageReference = FIRDatabase.database().reference().child("Messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                // to set all the messages of the same user in one cell
                let chatPartnerId = message.chatPartnerId()
                
                self.messagesDictionary[chatPartnerId] = message
                self.attemptReloadOfTable ()
                
            }
            }, withCancel: nil)
    }
    
    ////////////////////////////////////////////////////////////////
    //to setup the reloade method 
    private func attemptReloadOfTable (){
        //we need to reduce the number of reload thats way we use this way to reload the table
        self.timer?.invalidate()
        //to reload the tableView #to fix the bug where the images come wrong sometimes
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    ////////////////////////////////////////////////////////////////
    //to reload the message controller + resort the the messages dictionary // to minnimize the amount of sorting and enhance the performance
    func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        //to sort the messages by the time in a desending order
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    ////////////////////////////////////////////////////////////////
    //to state the number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    ////////////////////////////////////////////////////////////////
    //to set up the data inside each Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    ////////////////////////////////////////////////////////////////
    //return the hight for each row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        let chatPartnerId = message.chatPartnerId()
        
        let ref = FIRDatabase.database().reference().child("Users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject]
                else {
                  return
        }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
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
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
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



