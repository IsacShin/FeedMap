//
//  MapVC.swift
//  app
//
//  Created by 신이삭 on 2023/06/17.
//

import UIKit

class MapVC: BaseVC {
    
    convenience init() {
        self.init(nibName: "Map", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
