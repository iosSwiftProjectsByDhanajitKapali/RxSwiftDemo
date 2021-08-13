//
//  LoginViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 13/08/21.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet var userNameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observable1 = userNameTF.rx.text.orEmpty
        let observable2 = passwordTF.rx.text.orEmpty
        
        let observableCombined = Observable.combineLatest(observable1 ,observable2)
        
        self.loginButton.rx.tap
            .withLatestFrom(observableCombined)
            .subscribe(onNext: {
                userName , password in
                self.login(user: userName, pass: password)
            })
            .disposed(by: disposeBag)
        
    }
    
    func login(user: String, pass: String){
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailValid : Bool = emailTest.evaluate(with: user)
        let passValid : Bool = (pass != "" && pass.count >= 6)
        
        if(emailValid && passValid){
            print("Valid Credentials")
            let myProductListVC = self.storyboard?.instantiateViewController(identifier: "MyProductListSceneVC") as! ViewController
            self.navigationController?.pushViewController(myProductListVC, animated: true)
        }else{
            print("Wrong credentials")
        }
           
    }
    

}
