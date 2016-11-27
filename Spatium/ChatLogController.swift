//
//  ChatLogController.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "Cell"

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    ////////////////////////////////////////
    //to setup the user that the chat is esablished with
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let userMessageRef = FIRDatabase.database().reference().child("User-Messages").child(uid)
        
    
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            //snapshot would keep the message ID
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("Messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                //It has a potintional of crashing of the Keys dont match
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                print(message.text)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
                }, withCancel: nil)
            
            
            }, withCancel: nil)
        
        
    }
    
    ////////////////////////////////////////
    //set up the textfield
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self   //to help using Enter button to send
        
        return textField
    }()
    
    let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComonents()
    }
    
    ////////////////////////////////////////////////////
    //set up the number of the Cells in the ChatLog page
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    ////////////////////////////////////////////////////
    //set up the containt for each Cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.backgroundColor = UIColor.blue
        
        return cell
    }
    
    ////////////////////////////////////////////////////
    //set up the height and width for each Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.height, height: 80)
    }
    
    
    ////////////////////////////////////////////////////
    //set up the send message bar in the bottom of the new message View
    func setupInputComonents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //x,y, width, height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //set up the send button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
        
        //x,y,h,w
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        containerView.addSubview(inputTextField)
        
        //x,y,h,w
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        //x,y,h,w
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
    }
    
    ////////////////////////////////////////
    //to update the "messages" node in the Database and add the new message and user name
    func handleSend(){
        
        let ref = FIRDatabase.database().reference().child("Messages")
        let childRef = ref.childByAutoId()          //this will allow creating different ID for each message
        //is it the best thing to include the name  iside the message node
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = (Int(NSDate().timeIntervalSince1970)) as NSNumber
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        //childRef.updateChildValues(values)
        
        //add user messages child and keep a refrencing id for each user...
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            //to let the recipient also see the message
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
        
    }
    
    ////////////////////////////////////////
    //this optional method would call senButton whenever the Enter button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
