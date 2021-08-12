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
    - AsyncSubject -> emits only the last next event in the sequence, and only when the subject recieves a completed event
 
 Relays -> wrapper around subject that never complete
    -Publish Relay
    - Behaviour Relay
 
 */

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }


}

