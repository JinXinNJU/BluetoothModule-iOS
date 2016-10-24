//
//  ViewController.swift
//  CoreBluetooth
//
//  Created by Ezio Auditore on 5/1/15.
//  Copyright (c) 2015 Ezio Auditore. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        btDiscoverySharedInstance
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
}

