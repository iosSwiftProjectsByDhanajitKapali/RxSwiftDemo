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
    private let imagesArray = BehaviorRelay<[Data]>(value: [])
    
    
    //MARK: - IBOutlets
    @IBOutlet var imageSearchBar: UISearchBar!
    @IBOutlet var imagesCollectionView: UICollectionView!
    

}

//MARK: - Lifecycle methods
extension SearchImagesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchImagesViewModelInstance.fetchImages(withName: "car")
        
        
        bindUI()
        
    }
}


//MARK: - Private Functions
extension SearchImagesVC{
    
    func bindUI(){
        
        //subscribing to the viewModel
        searchImagesViewModelInstance.imagesViewModelObserver.subscribe(onNext: {
            theData in
            
            print(theData.count)
            self.imagesArray.accept(theData)
            
        }, onError: { theError in
            print("Error Occured ->\(theError)")
        }).disposed(by: disposeBag)
        

        
        
        //binding the data to the collection view
        imagesCollectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "cell")
        imagesArray.bind(to: imagesCollectionView.rx.items(cellIdentifier: "cell", cellType: MyCollectionViewCell.self)){
            indexPath, theData, cell in
            
        
            cell.myImageView.image = UIImage(data: theData)
        }.disposed(by: disposeBag)
        
    }
    
    
    
}
