//
//  SearchImagesVC.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import UIKit
import RxSwift
import RxCocoa

class SearchImagesVC: UIViewController {

    //MARK: - Private Variables
    private let disposeBag = DisposeBag()
    private let searchImagesViewModelInstance = SearchImagesViewModel()
    
    //MARK: - IBOutlets
    @IBOutlet var imageSearchBar: UISearchBar!
    

}

//MARK: - Lifecycle methods
extension SearchImagesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchImagesViewModelInstance.fetchImages(withName: "car")
        
        
        searchImagesViewModelInstance.imagesViewModelObserver.subscribe(onNext: {
            theData in
            
            print(theData.count)
            
        }, onError: { theError in
            
        }).disposed(by: disposeBag)
    }
}
