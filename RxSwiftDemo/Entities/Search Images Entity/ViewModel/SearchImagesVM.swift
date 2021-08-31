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
        
        DispatchQueue.main.async { [self] in
            
            
            //Check for the images in LocalDataBase
            imageArray = []
            let isImagesStored = getStoredImages(withName)
            
            if isImagesStored{
                //Images already stored
            }else{
                //Image not stored in database,So call api to get new Images
                imageArray = []
                fetchImages(withName: withName)
            }
        }
        
    }
    
    func getMoreImages(withName : String){
        fetchImages(withName: withName)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { [self] in
            getStoredImages(withName)
        }
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
                //self.imageArray = []
                //self.imagesViewModel.accept(self.imageArray)
                
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
        
        
    } //:fetchImage()
    
    
    func getStoredImages(withCategoryName : String) -> Bool{
        
        //create a new image Category
        let theImageCategory = RealmImageCategory()
        theImageCategory.imageCategoryName = withCategoryName
        
        let imagesData = theImageCategory.images.sorted(byKeyPath: "imageTitle")
        
        if imagesData.count > 0{
            for i in 0...imagesData.count {
                
                imageArray.append(imagesData[i].imageData)
            }
            imagesViewModel.accept(imageArray)
            return true
        }
        
        return false
    }
    
    func getStoredImages(_ ofCategoryName : String) -> Bool{
        
        //create a new image Category
        let theImageCategory = RealmImageCategory()
        theImageCategory.imageCategoryName = ofCategoryName
        
        //Get all the sored categories
        let realmCategoryArray = realm.objects(RealmImageCategory.self)
        if realmCategoryArray.count > 0{
            
            //check for the required category
            for i in 0...realmCategoryArray.count-1 {
                let realmCategory = realmCategoryArray[i]
                
                //found the required category
                if realmCategory.imageCategoryName == theImageCategory.imageCategoryName{
                    
                    //get all the images from this category
                    let imageDataArray = realmCategory.images
                    if imageDataArray.count > 0{
                        for i in 0...imageDataArray.count-1 {
                            let imageData = imageDataArray[i]
                            imageArray.append(imageData.imageData)
                        }
                        imagesViewModel.accept(imageArray)
                        return true
                    }
                }
                
            }
            
        }
        
        return false
    }
}
