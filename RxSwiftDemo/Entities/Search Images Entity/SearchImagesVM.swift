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
    var apiResponse : Observable<SearchedImagesModel>?
    private var urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4&query="

    
    private let imagesViewModel = BehaviorRelay<[ImagesViewModel]>(value: [])
    
    
    //MARK: - Public Variables
    var imagesViewModelObserver : Observable<[ImagesViewModel]>{
        return imagesViewModel.asObservable()
    }
    
}


//MARK: - Public Functions
extension SearchImagesViewModel{
    
    func fetchImages(withName: String){
        urlString += withName
        print(urlString)
        apiResponse = request.callAPI(forBaseUrlString: urlString, resultType: SearchedImagesModel.self)
        
        apiResponse?.subscribe(onNext: {
            apiResponseData in
            
            var imagesViewModelArray = [ImagesViewModel]()
            
            for i in 0...apiResponseData.results.count-1{
                let urlString = apiResponseData.results[i].urls.regular
                let image = ImagesViewModel(imageUrl: urlString)
                imagesViewModelArray.append(image)
            }
            
            self.imagesViewModel.accept(imagesViewModelArray)
    
            
        }, onError: { (error) in
            _ = self.imagesViewModel.catch { (error) in
                Observable.empty()
            }
            print(error.localizedDescription)
            
        }).disposed(by: disposeBag)
    }
}
