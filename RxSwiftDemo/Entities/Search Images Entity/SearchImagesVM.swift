//
//  SearchImagesVM.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import Foundation
import RxSwift
import RxCocoa

struct ImagesViewModel {
    let imageUrl : String
}

class SearchImagesViewModel {
    
    //MARK: - Private Variables
    private let disposeBag = DisposeBag()
    let request = APIRequest()
    var imagesDataFromApi : Observable<SearchedImagesModel>?
    private var urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4&query="

    private var imageDataFromApi : Observable<Data>?
    
    //private let imagesViewModel = BehaviorRelay<[ImagesViewModel]>(value: [])
    private let imagesViewModel = BehaviorRelay<[Data]>(value: [])
    private var imageArray = [Data]()
    
    //MARK: - Public Variables
//    var imagesViewModelObserver : Observable<[ImagesViewModel]>{
//        return imagesViewModel.asObservable()
//    }
    
    var imagesViewModelObserver : Observable<[Data]>{
        return imagesViewModel.asObservable()
    }
    
}


//MARK: - Public Functions
extension SearchImagesViewModel{
    
    func fetchImages(withName: String){
        urlString += withName
        print(urlString)
        imagesDataFromApi = request.callAPI(forBaseUrlString: urlString, resultType: SearchedImagesModel.self)
        
        imagesDataFromApi?.subscribe(onNext: {
            apiResponseData in
            
            //var imagesViewModelArray = [ImagesViewModel]()
            
            for i in 0...apiResponseData.results.count-1{
                let urlString = apiResponseData.results[i].urls.regular
                
                self.fetchImage(withUrlString: urlString)
                
                //let image = ImagesViewModel(imageUrl: urlString)
                //imagesViewModelArray.append(image)
            }
            
            //self.imagesViewModel.accept(imagesViewModelArray)
    
            
        }, onError: { (error) in
            print(error.localizedDescription)
            
        }).disposed(by: disposeBag)
    }
    
    func fetchImage(withUrlString : String){
        
        imageDataFromApi = request.getdata(fromUrl: withUrlString)
        
        
        imageDataFromApi?.subscribe(onNext: { [self]
            theData in
            imageArray.append(theData)
            imagesViewModel.accept(imageArray)
            
        }, onError: {
            theError in
            print(theError)
        }).disposed(by: disposeBag)
    }
}
