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

    //Creating a observable, will work as a datasource for the tableVIew
    let tableViewItems = Observable.just(["Item 1","Item 2", "Item 3", "Item 4" ])
    
    //creating a dispose bag
    let disposeBag = DisposeBag()
    
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bind the data to the tableView
        tableViewItems.bind(to: myTableView
                                .rx
                                .items(cellIdentifier: "myCell")){
            (tableView, tableViewData, cell) in
            cell.textLabel?.text = tableViewData
        }.disposed(by: disposeBag)
        
    }


}

