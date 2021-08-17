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

    @IBOutlet var myTextLabel: UILabel!
    @IBOutlet var mySearchBar: UISearchBar!
    @IBOutlet var myTextField: UITextField!
    @IBOutlet var myTextView: UITextView!
    @IBOutlet var mySlider: UISlider!
    @IBOutlet var myProgressView: UIProgressView!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myButton: UIButton!
    @IBOutlet var mySwitch: UISwitch!
    @IBOutlet var myActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var myStepper: UIStepper!
    @IBOutlet var mySegmentControl: UISegmentedControl!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        
    } //:viewDidLoad()
    
   
    
    
}

//MARK: - Test Various UI elements with Rx
extension ViewController{
    
    func testStepper(){
        //cahnge the slider value on pressing the stepper
        myStepper.rx.value.subscribe(onNext: {
            theValue in
            let valueInFloat = Float(theValue)
            print(valueInFloat)
            self.myProgressView.progress = valueInFloat/100
        }).disposed(by: disposeBag)
    }
    
    func testSegmentControl(){
        //changing the segment control will change the button background color
        mySegmentControl.rx.selectedSegmentIndex.subscribe(onNext: {
            theIndex in
            switch theIndex{
            case 0:
                self.myButton.backgroundColor = .red
            case 1:
                self.myButton.backgroundColor = .blue
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    func testImageView(){
        //add an image in the view asynchronously on a button tap
        myButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            self.myActivityIndicatorView.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                self.myImageView.image = UIImage(named: "testImage.png")
                self.myActivityIndicatorView.stopAnimating()
            }
            
        }).disposed(by: disposeBag)
    }
    
    func testSwitch(){
        mySwitch.rx.controlEvent(.valueChanged).withLatestFrom(mySwitch.rx.value).subscribe(onNext: {
            boolValue in
            print(boolValue)
        }).disposed(by: disposeBag)
    }
    
    func testButton(){
        //creating a observable from search bar text
        let obs1 = mySearchBar.rx.text.orEmpty
        myButton.rx.tap.withLatestFrom(obs1).subscribe(onNext: {
            temp in
            if self.validateString(temp: temp){
                print(temp)
            }
        }).disposed(by: disposeBag)
    }
    
    func testTextField(){
        //The textField is the observable and the textView is the observer
        myTextField.rx.text.subscribe(onNext: {
            theText in
            self.myTextView.text = theText
        }).disposed(by: disposeBag)
        
    }
    
    func testSlider(){
        //updating the progressview reactively with value from UISlider
        mySlider.rx.value.subscribe(onNext: {
            theValue in
            self.myProgressView.progress = theValue
        }).disposed(by: disposeBag)
    }
}


//MARK: - Private Functions
private extension ViewController{
    func validateString(temp : String) -> Bool{
        if temp.isEmpty{
            return false
        }else{
            return true
        }
    }
}

