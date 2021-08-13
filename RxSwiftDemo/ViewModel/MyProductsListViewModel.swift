//
//  MyProductsViewModel.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 13/08/21.
//

import UIKit
import RxSwift

final class MyProductsListViewModel{
    let title = "MyProducts"
    
    private let networkManager : NetworkManagerProtocol
    
    init(networkManager : NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchMyProductsViewModels() -> Observable<[MyProductViewModel]>{
        networkManager.fetchData().map { $0.map{
            MyProductViewModel(myProduct: $0) } }
    }
}

struct MyProductViewModel{
    private let myProduct : MyProduct
    
    var name : String{
        myProduct.name
    }
    
    var image : UIImage?{
        UIImage(systemName:myProduct.image)
    }
    
    init(myProduct : MyProduct) {
        self.myProduct = myProduct
    }
}
