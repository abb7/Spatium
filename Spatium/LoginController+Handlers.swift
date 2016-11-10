//
//  LoginController+Handlers.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    ////////////////////////////////////////////////////////////////
    // to start creating the new user and call the upload function
    func handleRegister(){
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form in not Valid")
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            //this will garante to get a unique ID every time an Image is uploaded
            
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("Profile_images").child("\(imageName).jpg")
            
            //we changed from UIImagePNG to UIImageJpg because it has a compression feature and '0.1' means 10% of the orignal size
            ////if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
            
            //and we define the constant 'profileImage' to remove uncertinty '!'
            //// if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, ErrorType) -> Void in
                    if error != nil{
                        print(error)
                        return
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageURL": profileImageURL ]
                        
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    ////////////////////////////////////////////////////////////////
    //upload the user information into the database
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]){
        let ref = FIRDatabase.database().reference()
        let usersRef = ref.child("Users").child(uid)
        usersRef.updateChildValues(values, withCompletionBlock: { (Err, ref) in
            
            if Err != nil {
                print(Err)
                return
            }
            //self.messagesContoller?.fetchUserAndSetUpNavBarTitle()
            
            //self.messagesContoller?.navigationItem.title = values["name"] as? String
            let user = User()
            user.setValuesForKeys(values)
            self.messagesContoller?.setupNavBarWithUser(user)
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    ////////////////////////////////////////////////////////////////
    //to let the gallery appear
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        //to let the user to be able to EDIT the Image
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////////////////////////
    //to you pick an image and be able to resize it or not and to choose it
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    ////////////////////////////////////////////////////////////////
    //to cancel the action of image picking
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel picker")
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

