//
//  ViewController.swift
//  ios-ci-sample
//
//  Created by Miklos Fazekas on 2016. 10. 19..
//  Copyright © 2016. Miklos Fazekas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var label: UILabel!

    @IBAction func sayHello(_ sender: AnyObject) {
        label.text = "Said hello!"
        label.textColor = UIColor.red
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

