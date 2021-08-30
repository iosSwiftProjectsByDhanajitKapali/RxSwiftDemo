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
    private let imageUrlList = BehaviorRelay<[ImagesViewModel]>(value: [])
    
    
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
            self.imageUrlList.accept(theData)
            
        }, onError: { theError in
            print("Error Occured ->\(theError)")
        }).disposed(by: disposeBag)
        
        
        //binding the data to the collection view
        imagesCollectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "cell")
        imageUrlList.bind(to: imagesCollectionView.rx.items(cellIdentifier: "cell", cellType: MyCollectionViewCell.self)){
            indexPath, theData, cell in
            
            cell.myImageView.image = UIImage(systemName: theData.imageUrl)
        }.disposed(by: disposeBag)
        
    }
    
    
    
}
