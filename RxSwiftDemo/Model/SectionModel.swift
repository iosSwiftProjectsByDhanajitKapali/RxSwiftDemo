//
//  SectionModel.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import Foundation
import RxDataSources

struct MySectionModel {
    var header : String
    var items : [MyProduct]
}

extension MySectionModel : SectionModelType{
    init(original: MySectionModel, items: [MyProduct]) {
        self = original
        self.items = items
    }
    
    
}
