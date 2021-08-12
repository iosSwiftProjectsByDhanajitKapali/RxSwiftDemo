//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    //creating a sectioned dataSource
    let tableViewItemsSectioned = BehaviorRelay.init(value: [
        MySectionModel(header: "Section 1", items: [MyProduct(name: "PaperPlane", image: "paperplane"),
                                                    MyProduct(name: "PaperPlabe", image: "paperplane.fill"),
                                                    MyProduct(name: "Trash", image: "trash"),
                                                    MyProduct(name: "Trash", image: "trash.fill"),
                                                    MyProduct(name: "Calendar", image: "calendar"),
                                                    MyProduct(name: "Calendar", image: "calendar.circle.fill")]),
        
        MySectionModel(header: "Section 1", items: [MyProduct(name: "Book", image: "book"),
                                                    MyProduct(name: "Book", image: "book.fill"),
                                                    MyProduct(name: "Person", image: "person"),
                                                    MyProduct(name: "Person", image: "person.fill")])
    ])
    
    //create a dispose bag
    let disposeBag = DisposeBag()
    
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet var mySearchBar: UISearchBar!
    
    //creating a section dataSource for the tableView
    let dataSource = RxTableViewSectionedReloadDataSource<MySectionModel>(configureCell: {
        dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = item.name
        cell.imageView?.image = UIImage(systemName: item.image)
        return cell
    }, titleForHeaderInSection: {
        dataSource, index in
        return dataSource.sectionModels[index].header
    })
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MyProducts"
        
        //Getting the String from the SearchBar
        _ = mySearchBar.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).distinctUntilChanged().map ({ query in
            
            self.tableViewItemsSectioned.value.map({
                mySectionedModel in
                MySectionModel(header: mySectionedModel.header, items: mySectionedModel.items.filter ({ myProduct in
                    query.isEmpty || myProduct.name.lowercased().contains(query.lowercased())
                }))
            })
            ///
        }).bind(to: myTableView
                    .rx
                    .items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        //Bind the model selected handler
        myTableView.rx.modelSelected(MyProduct.self).subscribe(onNext: { myProductObject in
            let myProductDetailsVC = self.storyboard?.instantiateViewController(identifier: "MyProductDetailsScene") as! MyProductDetailViewController
            myProductDetailsVC.myProductImageName.accept(myProductObject.image)
            self.navigationController?.pushViewController(myProductDetailsVC, animated: true)
        }).disposed(by: disposeBag)
        
        
    }
    
    
}

