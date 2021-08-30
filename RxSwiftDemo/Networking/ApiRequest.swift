//
//  ApiRequest.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 30/08/21.
//

import Foundation
import RxCocoa
import RxSwift

protocol APIRequestProtocol {
     func callAPI<T: Codable>(forBaseUrlString : String, resultType:T.Type) -> Observable<T>
}

class APIRequest: APIRequestProtocol {
    
    let session = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? = nil
    
    func callAPI<T: Codable>(forBaseUrlString : String, resultType:T.Type) -> Observable<T> {
        
        //create an observable and emit the state as per response.
        return Observable<T>.create { observer -> Disposable in
            
            //conver the URL String to URL
            guard let baseURL = URL(string: forBaseUrlString) else{
                observer.onError(NetworkingError.URL_PARSING_ERROR)
                return Disposables.create { }
            }
            
            self.dataTask = self.session.dataTask(with: baseURL, completionHandler: { (data, response, error) in
                do {
                    let model = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            })
            self.dataTask?.resume()
            return Disposables.create {
                self.dataTask?.cancel()
            }
        }
    }
}

enum NetworkingError : Error{
    case URL_PARSING_ERROR
}
