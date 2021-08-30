//
//  ImagesRealmModel.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import Foundation
import RealmSwift

class RealmImageCategory : Object{
    
    @objc dynamic var imageCategoryName : String = ""
    
    let images = List<RealmImage>()
    
}

class RealmImage : Object{
    @objc dynamic var imageTitle : String = ""
    @objc dynamic var imageData : Data = Data.init()
    
    //Backward Relation Between Data Objects
    var parentCategory = LinkingObjects(fromType : RealmImageCategory.self, property : "images")
}
