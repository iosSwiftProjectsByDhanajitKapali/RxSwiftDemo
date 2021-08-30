//
//  MyModel.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import Foundation

struct SearchedImagesModel : Codable{
    let total : Int
    let total_pages: Int
    let results : [TheResult]
}

struct TheResult : Codable {
    let id : String
    let urls : URLS
}

struct URLS : Codable{
    let full : String
    let regular : String
}


