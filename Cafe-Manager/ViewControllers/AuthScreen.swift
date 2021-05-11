//
//  AuthScreen.swift
//  FoodCafe
//
//  Created by Lahiru on 2/25/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class AuthScreen: UIViewController {

    enum FunctionMode{
        case login
        case register
    }
    @IBOutlet weak var email: PaddingTextUI!
    @IBOutlet weak var phonenumber: PaddingTextUI!
    @IBOutlet weak var password: PaddingTextUI!
    @IBOutlet weak var confirmPassword: PaddingTextUI!
    @IBOutlet weak var primaryBtn: RoundBtn!
    @IBOutlet weak var secondaryBtn: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    @IBOutlet weak var toast: Toast!
    @IBOutlet weak var textFieldContainer: UIStackView!
    var currentMode = FunctionMode.register
    var alertPop:AlertPopup!
    let auth = Auth.auth()
    override func viewDidLoad() {
        
        addDisableKeyboardOnUnFocus(fields: [email,password,phonenumber,confirmPassword])
        alertPop = AlertPopup(self)
    
        super.viewDidLoad()
        swapFunctioningMode()
        toast.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    func addDisableKeyboardOnUnFocus(fields:[UITextField]){
        for field in fields{
            field.delegate = self
        }
    }
    @IBAction func onForgetPassword(_ sender: Any) {
        if isEmpty([email]){
            return alertPop.infoPop(title: "Field Empty", body: "You should at least provide your email address for forget password")
        }
        auth.sendPasswordReset(withEmail: email.text!, completion: {error in
            if error == nil{
                self.showtoast(message: "A Email is successfully submited to \(self.email.text ?? "undefined")")
            }else{
                self.alertEmailValidationErrorIfPresent(err: error!)
            }
        })
    }
    
    //a commonly used function to validate if the error code is regarding email related validation
    //and pop the error message accordingly...
    func alertEmailValidationErrorIfPresent(err:Error){
        var message:String?
        switch AuthErrorCode(rawValue: err._code) {
        case .emailAlreadyInUse:
            message = "email is already in use.Please use another email"
        case.invalidEmail,.invalidRecipientEmail:
            message = "Invalid email address.Please enter a valid one"
        default:
            message = nil
        }
        if(message != nil){
            alertPop.infoPop(title: "Email field error", body: message!)
        }
    }
    func showtoast(message:String){
        //showing a toast like in android style with fade of animation after a delay,,,,
        toast.isHidden = false
        toast.alpha = 1.0
        toast.text = message
        UIView.animate(withDuration: 1.0, delay: 3, options: .curveEaseOut, animations: {
            self.toast.alpha = 0.0
        }, completion: {(isCompleted) in
            self.toast.isHidden = true
        })
    }
    
    @IBAction func primaryBtnTaped(_ sender: UIButton) {
        //based the current context user will sign up or sign in when tapping the primary button
        if currentMode == .login{
            loginUser()
        }else{
            registerUser()
        }
    }
    /*
     upon pressing ssecondary button the screen will toggle between login and register screens
     the only differance and with toggle between the the texfield to be wither shown or hidden
     */
    @IBAction func secondaryBtnTaped(_ sender: Any) {
        swapFunctioningMode()
    }
    
    func swapFunctioningMode(){
        currentMode = (currentMode == .login) ? .register:.login
        confirmPassword.isHidden = (currentMode == .login)
        phonenumber.isHidden = (currentMode == .login)
        forgetPassword.isHidden = (currentMode == .register)
        
        //changing the text of the buttons accordingly based on if to show login or register
        primaryBtn.setTitle(currentMode == .login ? "Login" : "Register", for: .normal)
        secondaryBtn.setTitle(currentMode == .login ? "Register?" : "Login?", for: .normal)
        
        //there is a bug that when the hidden textfield is shown there outline around the texfield get
        //dispareared so i manually set the borderline again when the texfield get appeared again....
        for view in textFieldContainer.subviews{
            let textfield = view as? UITextField
            if !(textfield?.isHidden ?? true) {
                textfield?.borderStyle = .line
            }
        }
        
    }
    func moveToMainScreen() {
        let mainScreen = self.storyboard!.instantiateViewController(identifier: "homeScreen")
        navigationController?.setViewControllers([mainScreen], animated: true)
        //navigationController?.setViewControllers([mainScreen], animated: true)
    }
    func loginUser(){
        alertPop.lastMessage = "trying to login"
        if(isEmpty([email,password])){
            return alertPop.infoPop(title: "Field error", body: "Some fields are empty")
        }
        auth.signIn(withEmail: email.text!, password: password.text!, completion: ({result,err in
            if(err == nil){
                //if the no error then user can navigate tp amin screen
                self.moveToMainScreen()
            }else{
                self.alertEmailValidationErrorIfPresent(err: err!)
                var message:String
                //the error code is test with case if the error is matching any of the following scenario..
                switch AuthErrorCode(rawValue: err!._code) {
                
                case .userNotFound,.wrongPassword:
                    message = "Wrong credendials.Please check your credentials"
                case .networkError:
                    message = "Something went wrong with connection.Try again later"
                default:
                    message = "unknown error had occured"
                }
                self.alertPop.lastMessage = message
                self.alertPop.infoPop(title: "Authentication failed", body:message )
            }
        }))
    }
    func isEmpty(_ fields:[UITextField]) -> Bool {
        //utility function is check if the field is empty
        for field in fields{
            if field.text == nil || field.text!.count == 0{
                return true
            }
        }
        return false
    }
    func  registerUser(){
        if(isEmpty([email,phonenumber,password,confirmPassword])){
            return alertPop.infoPop(title: "Field error", body: "Some fields are empty")
        }
        if(password.text! != confirmPassword.text!){
            return alertPop.infoPop(title: "Field mismatch", body: "confirmation password doesn't match")
        }
        if Int(phonenumber.text!) == nil || phonenumber.text!.count != 10{
            return alertPop.infoPop(title: "Invalid contact number", body: "the contact number provided should be 10 digits long numbert")
        }
        
        auth.createUser(withEmail: email.text!, password: password.text!, completion: ({result,err in
            if(err == nil){
                /*
                 if no error then user can proceed to register the account.Upon registering the the database will create
                 a docuemnt in 'orders' and 'user' collection with intitial data...
                 */
                let db = Firestore.firestore()
                db.document("user/\(result!.user.uid)").setData(["phoneNumber":self.phonenumber.text!])
                db.document("orders/\(result!.user.uid)").setData(["orderList":[]])
                self.moveToMainScreen()
            }else{
                self.alertEmailValidationErrorIfPresent(err: err!)
                 var message:String
                switch AuthErrorCode(rawValue: err!._code) {
                   case .networkError:
                       message = "Something went wrong with connection.Try again later"
                   case .weakPassword:
                       message = "passowrd is too weak"
                   default:
                       message = "unknown error had occured"
                   }
                self.alertPop.infoPop(title: "User registration failed", body:message )
            }
        }))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AuthScreen:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
