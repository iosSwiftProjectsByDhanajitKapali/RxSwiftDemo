//
//  MyProductDetailViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class MyProductDetailViewController: UIViewController {

    @IBOutlet var myProductImage: UIImageView!

    //created a Relay, which will emit a string element
    var myProductImageName : BehaviorRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bind this myProductImageName with myProductImageName
        myProductImageName.map ({ imageName in
            UIImage(systemName: imageName)
        }).bind(to: myProductImage
                    .rx
                    .image).disposed(by: disposeBag)
    }
    

}
