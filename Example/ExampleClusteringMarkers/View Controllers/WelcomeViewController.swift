//
//  WelcomeViewController.swift
//  ClusteringMarkers_Example
//
//  Created by Александр Смородов on 26.02.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openMap()
    }
    
    @IBAction func openMap(_ sender: Any? = nil) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
