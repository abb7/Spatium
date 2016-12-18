//
//  ChatInputContainerView.swift
//  Spatium
//
//  Created by Abb on 3/19/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView , UITextFieldDelegate{
    
    
    
    var chatLogController : ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(chatLogController?.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handleUploadTap)))

            
        }
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
    
    //set up the image to upload an image
    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload-image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return uploadImageView
    }()
    let sendButton = UIButton(type: .system)
    //let uploadImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        
        //set up the send button
        sendButton.setTitle("Send", for: .normal)
        
        //what is handle send
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)
        
        //x,y,h,w
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        addSubview(uploadImageView)
        //x,y,h,w
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        addSubview(self.inputTextField)
        
        //x,y,h,w
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        
        //x,y,h,w
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    ////////////////////////////////////////
    //this optional method would call senButton whenever the Enter button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
