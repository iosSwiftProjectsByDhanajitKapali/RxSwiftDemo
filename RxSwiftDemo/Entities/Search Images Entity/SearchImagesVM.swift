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
    private let request = APIRequest()
    private var urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4&query="
    private var imagesDataFromApi : Observable<SearchedImagesModel>?
    private var imageDataFromApi : Observable<Data>?
    
    private let imagesViewModel = BehaviorRelay<[Data]>(value: [])
    private var imageArray = [Data]()
    
    
    //MARK: - Public Variables
    var imagesViewModelObserver : Observable<[Data]>{
        return imagesViewModel.asObservable()
    }
    
}


//MARK: - Public Functions
extension SearchImagesViewModel{
    
    ///Use this method to fetch imageData for some image name
    func fetchImages(withName: String){
        urlString += withName
        print(urlString)
        imagesDataFromApi = request.callAPI(forBaseUrlString: urlString, resultType: SearchedImagesModel.self)
        
        imagesDataFromApi?.subscribe(onNext: {
            apiResponseData in
            
            for i in 0...apiResponseData.results.count-1{
                let urlString = apiResponseData.results[i].urls.regular
                    
                //Download the each image
                self.fetchImage(withUrlString: urlString)
            }
            
        }, onError: { (error) in
            print(error.localizedDescription)
            
        }).disposed(by: disposeBag)
    }
    
    ///Use this method to download an image
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
