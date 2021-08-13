//
//  AppCoordinator.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 13/08/21.
//

import UIKit

class AppCoordinator{
    
    private let window : UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start(){
        let viewController = ViewController.instantiate(viewModel: MyProductsListViewModel())
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
