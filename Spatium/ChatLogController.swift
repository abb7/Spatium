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

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid , let toId = user?.id else {
            return
        }
        let userMessageRef = FIRDatabase.database().reference().child("User-Messages").child(uid).child(toId)
        
    
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            //snapshot would keep the message ID
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("Messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else
                {
                    return
                }
                
                let message = Message()
                //It has a potintional of crashing of the Keys dont match
                message.setValuesForKeys(dictionary)
                
                
                //to filter the messages and show only the messages for the intended user
                //we fix this by interducing a sub child inside the uid
                
                self.messages.append(message)
                
                DispatchQueue.main.async
                    {
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
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView?.alwaysBounceVertical = true         //to let the page move up/down
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        //to let the keyboard follow the controller if it go up and down
        collectionView?.keyboardDismissMode = .interactive
        
//        setupKeyboardObservers()
    }
    
    ////////////////////////////////////////
    //to set up the inputContainerView for the text to be sent and to include it inside the inputAccessoryView
    //inputTextField would be outside it to be able to type on it
    lazy var inputContainerView : UIView  = {
        let containerView = UIView ()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
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
        
        //set up the image to upload an image
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload-image")
        containerView.addSubview(uploadImageView)
        //uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatLogController.handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        
        //x,y,h,w
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true

        
        containerView.addSubview(self.inputTextField)
        
        //x,y,h,w
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        //x,y,h,w
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return containerView
    }()
    
    func handleUploadTap(){
        let picker = UIImagePickerController()
        picker.delegate = self      //add 2 more libraries
        
        //to let the user to be able to EDIT the Image
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        
        //if edited
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        }
            //if not edited
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker{
                uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)

        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("Message-Images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("failed to upload the Image")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    self.sendMessageWithImageUrl(imageUrl: imageUrl)
                    
                }
                
                
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String){
        let ref = FIRDatabase.database().reference().child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = (Int(NSDate().timeIntervalSince1970)) as NSNumber
        let values = ["imageUrl": imageUrl, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            //to let the recipient also see the message
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////
    //attach the textField with the keyboard to show the keyboard whenever u press on it and to help drag it down when you swap down
    override var inputAccessoryView: UIView?{
        get {
            return inputContainerView
        }
    }
    
    ////////////////////////////////////////
    //to be able to see the inputAccessoryView
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    ////////////////////////////////////////
    //to Observe if the keyboard came up or down
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    ////////////////////////////////////////
    //to fix a memory leak where every time you exit chatlog it increase the number to call handleKeyboardWillHide
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    ////////////////////////////////////////
    //the actions that the app takes if the keyboard appear
    func handleKeyboardWillShow(notification: Notification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        //modify the bottomAnchor of the input container to be above the keybored
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        //to let the keyboard appeare
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    ////////////////////////////////////////
    //the actions that the app takes if the keyboard disappear
    func handleKeyboardWillHide(notification: Notification){
        containerViewBottomAnchor?.constant = 0
        
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        //to let the keyboard appeare
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()

    }
    }
    
    ////////////////////////////////////////////////////
    //set up the number of the Cells in the ChatLog page
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    ////////////////////////////////////////////////////
    //set up the containt for each Cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        //call the private function to modify the cell and the bubble
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        
        }

        
        return cell
    }
    
    ////////////////////////////////////////////////////
    //to set up the bubble features for each side and to put profile Image for the sender
    private func  setupCell(cell: ChatMessageCell, message: Message){
        
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.loadImageUsingCachWithUrlString(profileImageURL)
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCachWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
        
        //to state the color of the message bubble
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCachWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    ////////////////////////////////////////////////////
    //to fixes the rotation to look good
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    ////////////////////////////////////////////////////
    //set up the height and width for each Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        
        // get the estimated height some how????
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        //add width to fix the issue of resizeing after fliping the screen
        let width = UIScreen.main.bounds.width
        
        
        return CGSize(width: width, height: height)
    }
    
    ////////////////////////////////////////////////////
    //to estimate the size of the each message bubble
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?
    
    
    ////////////////////////////////////////
    //to update the "messages" node in the Database and add the new message and user name
    func handleSend(){
        
        let ref = FIRDatabase.database().reference().child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = (Int(NSDate().timeIntervalSince1970)) as NSNumber
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            //to let the recipient also see the message
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(toId).child(fromId)
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
