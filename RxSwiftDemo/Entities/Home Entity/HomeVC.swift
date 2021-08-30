//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet var searchImagesButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchImagesButton.layer.cornerRadius = 20
        signupButton.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
    }

}

