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
    private let userDefaults = UserDefaults.standard
    private let disposeBag = DisposeBag()
    private let dbManager = DBManager.shared
    private let request = APIRequest()
    private var urlString = "https://api.unsplash.com/search/photos?per_page=15&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4"
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
    
    func getMoreImages(withName : String){
        fetchImages(withName: withName)
        
        
    }
    
}

//MARK: - Private Methods
private extension SearchImagesViewModel{
   
    ///Use this method to fetch imageData for some image name
    func fetchImages(withName: String){
        
        //Get the page number to search images
        let savedPageNo = getPageNo(forCategoryName: withName)
        
        //create the URL
        let query = "&query=" + withName
        let pageNo = "&page=\(String(describing: savedPageNo))"
        
        
        let theUrl = urlString + query + pageNo
        print(theUrl)
        imagesDataFromApi = request.callAPI(forBaseUrlString: theUrl, resultType: SearchedImagesModel.self)
        
        imagesDataFromApi?.subscribe(onNext: {
            apiResponseData in
            
            
            let theCategory = self.saveNewCategoryInDB(withName: withName)
            
            //parse the data from api
            if apiResponseData.results.count > 0{
                //remove the previous images from data source
                self.imageArray = []
                self.imagesViewModel.accept(self.imageArray)
                
                for i in 0...apiResponseData.results.count-1{
                    let urlString = apiResponseData.results[i].urls.thumb
                        
                    //Download each image
                    self.fetchImage(withUrlString: urlString, andImageID: apiResponseData.results[i].id, ofCategory: theCategory)
                }
            }

            
        }, onError: { (error) in
            print(error.localizedDescription)
            
        }).disposed(by: disposeBag)
    }
    
    func getPageNo(forCategoryName : String) -> Int{
        var savedPageNo : Int?
        savedPageNo = userDefaults.integer(forKey: forCategoryName)
        if let theSavedPageNo = savedPageNo {
            if theSavedPageNo == 0{
                savedPageNo! += 1
            }
        }
        //store the CategoryName with its pageNo in UserDefaults
        userDefaults.setValue(savedPageNo, forKey: forCategoryName)
        
        return savedPageNo!
    }
    
    func saveNewCategoryInDB(withName : String) -> RealmImageCategory{
        var categoryToBeReturned : RealmImageCategory
        
        //create a new image Category
        let newImageCategory = RealmImageCategory()
        newImageCategory.imageCategoryName = withName
        
        categoryToBeReturned = newImageCategory
        
        DispatchQueue.main.async { [self] in
            
            //get all the stored categories
            self.realmImageCategoryArray = self.realm.objects(RealmImageCategory.self)
            var flag = 0
            
            //check if current category is Present or not
            if let realmImageCategoryArray = realmImageCategoryArray{
                if realmImageCategoryArray.count > 0{
                    for i in 0...realmImageCategoryArray.count-1 {
                        let realmCategory = realmImageCategoryArray[i]
                        if realmCategory.imageCategoryName == newImageCategory.imageCategoryName{
                            //category found, no need to save it again
                            flag = 1
                            categoryToBeReturned = realmCategory
                        }
                    }
                }
            }
            
            //Category not found so save the newImageCtegory
            if flag == 0{
                do{
                    try self.realm.write{
                        self.realm.add(newImageCategory)
                        categoryToBeReturned = newImageCategory
                    }
                }catch{
                    print("Error saving the context\(error)")
                }
            }
            
        } //:DispatchQueue.main.async
        return categoryToBeReturned
    }
    
    
    ///Use this method to download an image
    func fetchImage(withUrlString : String, andImageID : String, ofCategory : RealmImageCategory){
        
        imageDataFromApi = request.getdata(fromUrl: withUrlString)
        
        
        imageDataFromApi?.subscribe(onNext: { [self]
            theData in
            
            //Store the Images in Local DataBase
            DispatchQueue.main.async {
                do{
                    try self.realm.write{
                        let newImage = RealmImage()
                        newImage.imageTitle = andImageID
                        newImage.imageData = theData
                        
                        ofCategory.images.append(newImage)
                    }
                }catch{
                    print("Error saving new Image\(error)")
                }
            }
            
            //Populate the BehaviourRelay
            //imageArray.append(theData)
            //imagesViewModel.accept(imageArray)
            
            
        }, onError: {
            theError in
            print(theError)
        }).disposed(by: disposeBag)
        
        getStoredImages(ofCategory: ofCategory)
        
    } //:fetchImage()
    
    
    func getStoredImages(ofCategory : RealmImageCategory){
        
        DispatchQueue.main.async { [self] in
            let imagesData = ofCategory.images.sorted(byKeyPath: "imageTitle")
            
            if imagesData.count > 0{
                for i in 0...imagesData.count {
                    
                    imageArray.append(imagesData[i].imageData)
                }
                imagesViewModel.accept(imageArray)
            }
        }
        
        
    }
}
