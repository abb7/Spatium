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
import MobileCoreServices
import AVFoundation

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
                
                guard let dictionary = snapshot.value as? [String: AnyObject]
                    else {
                    return
                }
                
                //let message = Message(dictionary: dictionary)
                //It has a potintional of crashing of the Keys dont match
                //message.setValuesForKeys(dictionary)
                
                
                //to filter the messages and show only the messages for the intended user
                //we fix this by interducing a sub child inside the uid
                
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    
                    //scroll to the last index
                    ////////////////////////////////////////
                    //a potential of failur ever time we open new chat not on memory
                    //if self.messages.count > 1 {
                        //print (self.messages.count)
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
                    //}
                    
                }
                
                }, withCancel: nil)
            
            
            
            
            }, withCancel: nil)
        
        
    }
    
    
    
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
        
        setupKeyboardObservers()
    }
    
    ////////////////////////////////////////
    //to set up the inputContainerView for the text to be sent and to include it inside the inputAccessoryView
    //inputTextField would be outside it to be able to type on it
    lazy var inputContainerView : ChatInputContainerView  = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView

    }()
    
    func handleUploadTap(){
        let picker = UIImagePickerController()
        picker.delegate = self      //add 2 more libraries
        picker.allowsEditing = true
        // add media type to include videos in the picker
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(picker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            //we selected a video
            handleVideoSelectedForUrl(url: videoUrl)
        } else {
            //we selected an image
            handleImageSelectedForInfoDictionary(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //handle the upload of a vided
    private func handleVideoSelectedForUrl (url : URL) {
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("Message_Movies").child(filename).putFile(url , metadata: nil, completion:
            { (metadata, error) in
                if error != nil {
                    print("Field to upload the video: ", error)
                    return
                }
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    print (videoUrl)
                    

                    //to provide a dammy image and to set up the bubble siez for it
                    if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                        
                       self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let properties : [String: AnyObject] = ["imageUrl" : imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject,"imageHeight": thumbnailImage.size.height as AnyObject , "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                        
                       })
                    }
                }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage =  try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print (err)
        }
        return nil
    }

    //handle the uploade of an image
    private func handleImageSelectedForInfoDictionary(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        //if edited
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            // if not edited
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            self.uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl,image: selectedImage)
            })
        }
        

    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("Message-Images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("failed to upload the Image")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
                
            })
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboradDidShow), name: .UIKeyboardDidShow, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func handleKeyboradDidShow(){
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
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
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.message = message 
        cell.textView.text = message.text
        
        //call the private function to modify the cell and the bubble
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            //this is a Text Message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //this an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true

        }
        
        cell.playButton.isHidden = message.videoUrl == nil          //(this shorter for) if message.videoUrl != nil { cell.playButton.isHidden = false } else { cell.playButton.isHidden = true }
    
        return cell
    }
    
//    func handleImageTapping(){
//        print("Image has been tapped")
//    }
    
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
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            //(height 1 / width 1) = (height 2 / width 2)
            //solve for height 1
            // height 1 = ( height 2 / ( width 2 * width 1 ))
            height = CGFloat(imageHeight / imageWidth * 200)
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
        
        let properties : [String: AnyObject] = ["text": inputContainerView.inputTextField.text! as AnyObject]
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let properties : [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject,"imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties: properties)
        
        
    }

    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let ref = FIRDatabase.database().reference().child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = (Int(NSDate().timeIntervalSince1970)) as NSNumber
        var values: [String : Any] = ["toId": toId, "fromId": fromId, "timeStamp": timeStamp]
        
        //appennd properties dictionary onto values somehow???
        //key $0 and value $1
        properties.forEach({values [$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            //to let the recipient also see the message
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("User-Messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }

    }
    
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    //my custome Zooming logic
    func perfurmZoomInForStartingImageView(startingImageView: UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        //to add a new window
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            //this type of animation is snapy and feels fast
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                //**MATH**
                //  h2/w2 = h1/w1
                //  h2 = h1 / w1 * w2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
                }, completion: nil)
        
        }
    }
    
    
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                }, completion: { (completed: Bool) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
            })
            
        }
        
    
    }
}
