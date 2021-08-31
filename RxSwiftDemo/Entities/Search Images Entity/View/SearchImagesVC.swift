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
    
    let searchImagesViewModelInstance = SearchImagesViewModel()
    let imagesArray = BehaviorRelay<[Data]>(value: [])
    var searchQuery : String = ""
    
    //MARK: - IBOutlets
    @IBOutlet var imageSearchBar: UISearchBar!
    @IBOutlet var imagesCollectionView: UICollectionView!
    

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if let queryText = imageSearchBar.text , !queryText.isEmpty{
            //searchImagesViewModelInstance.fetchImages(withName: queryText)
            searchImagesViewModelInstance.getImages(withName: queryText)
            searchQuery = queryText
            imageSearchBar.text = ""
        }
    }
}

//MARK: - Lifecycle methods
extension SearchImagesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetup()
        
        bindUI()
        
    }
}


//MARK: - Private Functions
extension SearchImagesVC{
    
    func initialSetup(){
        self.imagesCollectionView.delegate = self
    }
    
    func bindUI(){
        
        //subscribing to the viewModel
        searchImagesViewModelInstance.imagesViewModelObserver.subscribe(onNext: {
            theData in
            
            print("Image Data count -> \(theData.count)")
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
