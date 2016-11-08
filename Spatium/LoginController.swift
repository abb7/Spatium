//
//  LoginController.swift
//  Spatium
//
//  Created by Abb on 2/8/1438 AH.
//  Copyright © 1438 Abb. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    
    var messagesContoller: MessagesController?
    
    ////////////////////////////////////////////////////////////////
    //Create the input view
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the button that will be used for register/login
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(LoginController.handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the name text field that will be on the input container view
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the seprator that will appear under the name text field view
    let nameSepratorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the email text field that will be on the input container view
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email address"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the seprator that will appear under the email text field view
    let emailSepratorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the password text field that will be on the input container view
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    ////////////////////////////////////////////////////////////////
    //Creat the profile image view that will appear on the login/register view
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "winter_is_coming")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginController.handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    ////////////////////////////////////////////////////////////////
    //Create the segmented controller that will switch between register/login
    lazy var loginRegisterSegmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl (items: ["Login" , "Register"])
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(LoginController.handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setUpLoginRegisterSegmentedControl()

    }

    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameInputFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    ////////////////////////////////////////////////////////////////
    //Set up the container view of texts for registeration/loging in
    func setupInputsContainerView(){
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSepratorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSepratorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        //NAME TEXT FIELD//
        //need x, y, width, height constraints
        //For the name text field
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameInputFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameInputFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        //For the name Seprator
        nameSepratorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSepratorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSepratorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSepratorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //EMAIL TEXT FIELD//
        //need x, y, width, height constraints
        //For the email text field
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        //For the email seprator
        emailSepratorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSepratorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSepratorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSepratorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Password TEXT FIELD//
        //need x, y, width, height constraints
        //For the password text field
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    
    ////////////////////////////////////////////////////////////////
    //Set up the login/register button
    func setupLoginRegisterButton(){
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    ////////////////////////////////////////////////////////////////
    //Set up the profile Image
    func setupProfileImageView(){
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: inputsContainerView.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    
    
    ////////////////////////////////////////////////////////////////
    //Set up the login/register segmented control
    func setUpLoginRegisterSegmentedControl(){
        //need x, y, width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        
    }
    
    ////////////////////////////////////////////////////////////////
    //To check if the action selected from the segemented control is either Login or Register
    func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    ////////////////////////////////////////////////////////////////
    //to handle the login process and pass the user in
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("Form in not Valid")
                return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (User, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            //if successfully logged in it will dismiss the current viewController
            
            self.messagesContoller!.fetchUserAndSetUpNavBarTitle()
            //self.messagesContoller?.navigationController?.title = Values[name] as? String
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    ////////////////////////////////////////////////////////////////
    //to change the inputContainerView from the Register to Login
    func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        //Change height of inputsContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //change the height of the name text field
        
        nameInputFieldHeightAnchor!.isActive = false
        //        nameInputFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? ((inputsContainerView.heightAnchor.value(forKey: nameInputFieldHeightAnchor))  * 1/3) && nameTextField.isHidden = false : nameTextField.isHidden = true)
        
        if (loginRegisterSegmentedControl.selectedSegmentIndex == 0){
            nameInputFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
            
            nameTextField.isHidden = true
        }
        else {
            nameTextField.isHidden = false
            nameInputFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        }
        
        //inputsContainerView.heightAnchor, multiplier: (loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3))
        nameInputFieldHeightAnchor!.isActive = true
        
        //change the height of the Email text field
        emailTextFieldHeightAnchor!.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: (loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3))
        emailTextFieldHeightAnchor!.isActive = true
        
        //chang the height of the Password text field
        passwordTextFieldHeightAnchor!.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: (loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3))
        passwordTextFieldHeightAnchor!.isActive = true
        
    }
    
    ////////////////////////////////////////////////////////////////
    //to change the Status and time bar to white color
    override var preferredStatusBarStyle : UIStatusBarStyle {       //time/battary status bar color
        return .lightContent
    }
    
}


////////////////////////////////////////////////////////////////
//to add an easier way to define colors
extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }

   

}
