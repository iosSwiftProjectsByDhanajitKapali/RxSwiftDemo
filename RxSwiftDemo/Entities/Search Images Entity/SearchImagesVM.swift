//
//  SearchImagesVM.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

struct ImagesViewModel {
    let imageUrl : String
}

class SearchImagesViewModel {
    
    //MARK: - Private Variables
    let realm = try! Realm()
    private let disposeBag = DisposeBag()
    private let dbManager = DBManager.shared
    private let request = APIRequest()
    private var urlString = "https://api.unsplash.com/search/photos?page=1&per_page=5&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4&query="
    private var imagesDataFromApi : Observable<SearchedImagesModel>?
    private var imageDataFromApi : Observable<Data>?
    
    private let imagesViewModel = BehaviorRelay<[Data]>(value: [])
    private var imageArray = [Data]()
    
    private var realmImageCategoryArray : Results<RealmImageCategory>?
    private var realmImagesArray : Results<RealmImage>?
    
    //MARK: - Public Variables
    var imagesViewModelObserver : Observable<[Data]>{
        return imagesViewModel.asObservable()
    }
    
}


//MARK: - Public Functions
extension SearchImagesViewModel{
    
    func getImages(withName : String){
        
        var flag = 0;
        
        //Check for the images in LocalDataBase
        DispatchQueue.main.async { [self] in
            
            //get all the stored categories
            self.realmImageCategoryArray = self.realm.objects(RealmImageCategory.self)
            
            //create a new image Category
            let newImageCategory = RealmImageCategory()
            newImageCategory.imageCategoryName = withName
            
            if let realmImageCategoryArray = realmImageCategoryArray{
                
                //check if this newly created catrgory is already saved in the database or not
                if realmImageCategoryArray.count > 0{
                    for i in 0...realmImageCategoryArray.count-1{
                        if realmImageCategoryArray[i].imageCategoryName == newImageCategory.imageCategoryName{
                            //image Category already there in RealmDB
                            //Got the required imageData
                            let realmImageCategory = realmImageCategoryArray[i]
                            if realmImageCategory.images.count > 0{
                                imageArray = []
                                flag = 0
                                for i in 0...realmImageCategory.images.count-1{
                                    //get all the images
                                    imageArray.append(realmImageCategory.images[i].imageData)
                                }
                                imagesViewModel.accept(imageArray)
                                return
                            }
                            
                        }else{
                            flag = 1
                        }
                    }
                }else{
                    flag = 1
                }
                
            }
            
            //No image Found in the LocalDB, so fetch it via API call
            if flag == 1{
                fetchImages(withName: withName)
            }

            
        } //:DispatchQueue.main.async
        
    }
    
    ///Use this method to fetch imageData for some image name
    func fetchImages(withName: String){
        let theUrl = urlString + withName
        print(theUrl)
        imagesDataFromApi = request.callAPI(forBaseUrlString: theUrl, resultType: SearchedImagesModel.self)
        
        imagesDataFromApi?.subscribe(onNext: {
            apiResponseData in
            
            //create a new image Category
            let newImageCategory = RealmImageCategory()
            newImageCategory.imageCategoryName = withName
            
            DispatchQueue.main.async {
                do{
                    try self.realm.write{
                        self.realm.add(newImageCategory)
                    }
                }catch{
                    print("Error saving the context\(error)")
                }
            }
            
            
            //parse the data from api
            if apiResponseData.results.count > 0{
                //remove the previous images from data source
                self.imageArray = []
                self.imagesViewModel.accept(self.imageArray)
                
                for i in 0...apiResponseData.results.count-1{
                    let urlString = apiResponseData.results[i].urls.regular
                        
                    //Download each image
                    self.fetchImage(withUrlString: urlString, ofCategory: newImageCategory)
                }
            }

            
        }, onError: { (error) in
            print(error.localizedDescription)
            
        }).disposed(by: disposeBag)
    }
    
   
}

//MARK: - Private Methods
private extension SearchImagesViewModel{
   
//    func getImagesFromRealmDB() -> Results<RealmImageCategory>?{
//        realmImageCategoryArray = realm.objects(RealmImageCategory.self)
//        return realmImageCategoryArray
//    }
    
    ///Use this method to download an image
    func fetchImage(withUrlString : String, ofCategory : RealmImageCategory){
        
        imageDataFromApi = request.getdata(fromUrl: withUrlString)
        
        
        imageDataFromApi?.subscribe(onNext: { [self]
            theData in
            
            //Store the Images in Local DataBase
            DispatchQueue.main.async {
                do{
                    try self.realm.write{
                        let newImage = RealmImage()
                        newImage.imageTitle = ""
                        newImage.imageData = theData
                        
                        ofCategory.images.append(newImage)
                    }
                }catch{
                    print("Error saving new Image\(error)")
                }
            }
            
            //Populate the BehaviourRelay
            imageArray.append(theData)
            imagesViewModel.accept(imageArray)
            
        }, onError: {
            theError in
            print(theError)
        }).disposed(by: disposeBag)
    }
}
