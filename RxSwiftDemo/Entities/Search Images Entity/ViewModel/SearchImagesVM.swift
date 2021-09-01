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
    private var urlString = "https://api.unsplash.com/search/photos?per_page=3&client_id=2Fi9NCnEw5unBwaeyEkN-VWr0Q7niaViO1jKoeGa0D4"
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
        
        //Check for the images in LocalDataBase
        imageArray = []
        getStoredImages(withName)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { [self] in
            
            if imageArray.count == 0{
                //Image not stored in database,So call api to get new Images
                imageArray = []
                fetchImages(withName: withName)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    getStoredImages(withName)
                }
            }
        }
        
        
    }
    
    func getMoreImages(withName : String){
        fetchImages(withName: withName)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) { [self] in
            let  _ = getStoredImages(withName)
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
            
            
            //Create and store the category in the Local Storage
            let theCategory = self.saveNewCategoryInDB(withName: withName)
            
            //parse the data from api
            if apiResponseData.results.count > 0{
                
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
    
    
    ///Use this method to get the PageNo for the required Category
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
    
    
    ///Use thie method to creat and store a new RealmImageCategory if its not already present in the Local Storage
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
            storeImageInDB(ofImageID: andImageID, andData: theData, ofCategory: ofCategory)
            
        }, onError: {
            theError in
            print(theError)
        }, onCompleted: { [self] in
            
            //getStoredImages(ofCategory.imageCategoryName)
            
        }).disposed(by: disposeBag)
        
        
    } //:fetchImage()
    
    
    ///Use this method to Store images in the Local Storage
    func storeImageInDB(ofImageID : String, andData : Data, ofCategory : RealmImageCategory){
        DispatchQueue.main.async {
            do{
                try self.realm.write{
                    let newImage = RealmImage()
                    newImage.imageTitle = ofImageID
                    newImage.imageData = andData
                    
                    ofCategory.images.append(newImage)
                }
            }catch{
                print("Error saving new Image\(error)")
            }
        }
    } //:storeImageInDB()
    
    
    ///Use this method to Fetch images from the Local Storage
    func getStoredImages(_ ofCategoryName : String){
        
        //accessing DB from Main thread
        DispatchQueue.main.async { [self] in

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
                           
                        }
                    }
                    
                }
                
            }
        }
        
    } //:getStoredImages()
}
