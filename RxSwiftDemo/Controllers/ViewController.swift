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
    
    //making it a BehaviourRelay, will work as datasource for myTableView
    let tableViewItems = BehaviorRelay.init(value: [MyProduct(name: "PaperPlane", image: "paperplane"),
                                                    MyProduct(name: "PaperPlabe", image: "paperplane.fill"),
                                                    MyProduct(name: "Trash", image: "trash"),
                                                    MyProduct(name: "Trash", image: "trash.fill"),
                                                    MyProduct(name: "Calendar", image: "calendar"),
                                                    MyProduct(name: "Calendar", image: "calendar.circle.fill"),
                                                    MyProduct(name: "Book", image: "book"),
                                                    MyProduct(name: "Book", image: "book.fill"),
                                                    MyProduct(name: "Person", image: "person"),
                                                    MyProduct(name: "Person", image: "person.fill")])
    
    //create a dispose bag
    let disposeBag = DisposeBag()
    
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet var mySearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MyProducts"
        
        //Getting the String from the SearchBar
        _ = mySearchBar.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).distinctUntilChanged().map ({ query in
            self.tableViewItems.value.filter ({ myProduct in
                query.isEmpty || myProduct.name.lowercased().contains(query.lowercased())
            })
        }).bind(to: myTableView
                    .rx
                    .items(cellIdentifier: "myCell")){
            (tableView, tableViewData, cell) in
            cell.textLabel?.text = tableViewData.name
            cell.imageView?.image = UIImage(systemName: tableViewData.image)
        }.disposed(by: disposeBag)
        
        //Bind the model selected handler
        myTableView.rx.modelSelected(MyProduct.self).subscribe(onNext: { myProductObject in
            let myProductDetailsVC = self.storyboard?.instantiateViewController(identifier: "MyProductDetailsScene") as! MyProductDetailViewController
            myProductDetailsVC.myProductImageName.accept(myProductObject.image)
            self.navigationController?.pushViewController(myProductDetailsVC, animated: true)
        }).disposed(by: disposeBag)
        
        
    }
    
    
}

