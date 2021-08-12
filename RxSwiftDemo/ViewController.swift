//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit
import RxSwift
import RxCocoa

//Model
struct Product{
    let imageName : String
    let title : String
}

//ViewModel
struct ProductViewModel{
    //item to Published
    var items = PublishSubject<[Product]>()
    
    func fetchItems(){
        let products = [
            Product(imageName: "house", title: "Home"),
            Product(imageName: "gear", title: "Settings"),
            Product(imageName: "person.circle", title: "Profile"),
            Product(imageName: "airplane", title: "Flights"),
            Product(imageName: "bell", title: "Activity")
        ]
        items.onNext(products)
        items.onCompleted()
    }
}


class ViewController: UIViewController {

    //creating the tableView
    private let tableView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var viewModel = ProductViewModel()
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the tableView
        view.addSubview(tableView)
        tableView.frame = view.bounds
            
        bindTableData()
    }

    func bindTableData(){
        //Bind items from ViewModel to tableView
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){
            row, model, cell in
            
            cell.textLabel?.text = model.title
            cell.imageView?.image = UIImage(systemName: model.imageName)
        }.disposed(by: bag)
        
        //Bind a model selected handler
        tableView.rx.modelSelected(Product.self).bind{
            product in
            print(product.title)
        }.disposed(by: bag)
        
        //fetch items
        viewModel.fetchItems()
    }

}

