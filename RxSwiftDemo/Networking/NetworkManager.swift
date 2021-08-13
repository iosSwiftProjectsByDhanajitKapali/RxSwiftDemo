//
//  NetworkManager.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 13/08/21.
//

import Foundation
import RxSwift

class NetworkManager{
    
    func fetchData() -> Observable<[MyProduct]>{
        
        return Observable.create { observer -> Disposable in
            
            guard let path = Bundle.main.path(forResource: "myProduct", ofType: "json")else{
                print("myProduct.json file nahi mila")
                observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                return Disposables.create {  }
            }
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let myProducts = try JSONDecoder().decode([MyProduct].self,from: data)
                observer.onNext(myProducts)
            } catch{
                print("Got error wile fetching the data from json file, or either while decoding the data", error)
                observer.onError(error)
            }
            
            return Disposables.create {  }
        }
        
    } //:fetchData()
}
