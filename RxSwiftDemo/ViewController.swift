//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by unthinkable-mac-0025 on 12/08/21.
//


/*
 Observable (sequence) - emits events (notification of change) asynchronously
 Observer - subscribes to Observable in order to recieve events
 
 Subject -> Observable + Observer
    - PublishSubject -> only emits new elements to subscribers
    - BehaviourSubject -> emits the last element to the subscribers
    - ReplaySubject -> emits the elements to the subscriber as according to the buffer size
    - AsyncSubject -> emits only the second last event in the sequence, that only when the subject recieves a completed event
 
 Relays -> wrapper around subject that never complete
    - Publish Relay
    - Behaviour Relay
 
 */

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ViewController: UIViewController {

    //create a dispose bag
    let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        behaviourRelayDemo()
        
    }

    func publishSubjectDemo(){
        //created a new PublishSubject, which will emit String elements
        let pSub = PublishSubject<String>()
        pSub.onNext("PS E1")    //emit a new element
        
        _ = pSub.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        pSub.onNext("PS E2")    //only this new emitted element is observed by the subscriber
    }
    
    func behaviourSubjectDemo(){
        let bSub = BehaviorSubject<String>(value: "BS E1")
        bSub.onNext("BS E2")
        
        _ = bSub.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        //Note:- The subscriber will recieve either the last emitted element or the default value/element
    }
    
    func replaySubjectDemo(){
        let rSub = ReplaySubject<String>.create(bufferSize: 3)
        rSub.onNext("RS E1")
        rSub.onNext("RS E2")
        rSub.onNext("RS E3")
        
        _ = rSub.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        //Note:- The subscriber will recieve the last emitted elements according to the buffer size
    }
    
    func asyncSubjectDemo(){
        let aSub = AsyncSubject<String>()
        aSub.onNext("AS E1")
        aSub.onNext("AS E2")
        
        aSub.onCompleted()
        
        _ = aSub.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        //Note:- The subscriber will not recive, until the onCompleted event is not emitted by the publisher
    }
    
    //MARK: - Relays
    //Relays Never emit onCompleted event, Suitable to UI work
    
    func publishRelayDemo(){
        let pRel = PublishRelay<String>()
        pRel.accept("PREL E1")              //equivalent to onNext()
        
        _ = pRel.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        pRel.accept("PREL E2")
        
        //Note:- Only those events will be observed by the observer, which are emitted after in subscribed
    }
    
    func behaviourRelayDemo() {
        let bRel = BehaviorRelay<String>(value: "BREL E1")
        bRel.accept("BREL E1")              //equivalent to onNext()
        
        _ = bRel.subscribe(onNext: {
            element in
            print(element)              //this subscriber print the element
        }).disposed(by: disposeBag)
        
        bRel.accept("BREL E2")
        
        
    }
    
    

}

