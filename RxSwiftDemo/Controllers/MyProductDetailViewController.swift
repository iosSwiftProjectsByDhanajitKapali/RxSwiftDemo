//
//  MyProductDetailViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit

class MyProductDetailViewController: UIViewController {

    @IBOutlet var myProductImage: UIImageView!

    var myProductImageName = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()

        myProductImage.image = UIImage(systemName: myProductImageName)
    }
    

}
