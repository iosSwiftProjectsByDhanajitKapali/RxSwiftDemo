//
//  UserViewModel.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 13/08/21.
//

import Foundation
import RxSwift
import RxCocoa

struct UserDetailModel {
    var userData = UserDetail(id: 1, email: "abc@gmail.com", first_name: "abc", last_name: "xyz", avatar: "avatar")
    var isFavorite: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isFavObservable: Observable<Bool> {
        return isFavorite.asObservable()
    }
}

class UserViewModel {
    
    let request = APIRequest()
    var apiResponse : Observable<DataModel>?
    private let userViewModel = BehaviorRelay<[UserDetailModel]>(value: [])
    var userViewModelObserver: Observable<[UserDetailModel]> {
        return userViewModel.asObservable()
    }
    
    private let disposeBag = DisposeBag()
    
    func fetchUserList() {
        apiResponse = request.callAPI(forBaseUrlString: "https://reqres.in/api/users", resultType: DataModel.self)
        apiResponse?.subscribe(onNext: {
            apiResponseData in
            
            var userViewModelArray = [UserDetailModel]()
            if let users = apiResponseData.data{
                for index in 0..<users.count {
                    var user = UserDetailModel()
                    user.userData = users[index]
                    userViewModelArray.append(user)
                }
                self.userViewModel.accept(userViewModelArray)
            }
            
        }, onError: { (error) in
            _ = self.userViewModel.catch { (error) in
                Observable.empty()
            }
            print(error.localizedDescription)
        
        }).disposed(by: disposeBag)

    } //:fetchUserList()
}
