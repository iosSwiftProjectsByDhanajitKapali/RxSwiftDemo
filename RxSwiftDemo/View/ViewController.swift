//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private var viewModel : MyProductsListViewModel!
    
    @IBOutlet var myTableView: UITableView!
    
    static func instantiate(viewModel : MyProductsListViewModel) -> ViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateInitialViewController() as! ViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.tableFooterView = UIView()
        
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        myTableView.contentInsetAdjustmentBehavior = .never
        
        viewModel.fetchMyProductsViewModels().observe(on: MainScheduler.instance).bind(to: myTableView.rx.items(cellIdentifier: "myCell")){
            index, viewModel, cell in
            cell.textLabel?.text = viewModel.name
            cell.imageView?.image = viewModel.image
        }.disposed(by: disposeBag)
    }


}

