//
//  DiscoverVC.swift
//  OCBCPayNow
//
//  Created by admin on 7/10/21.
//

import UIKit
import PaceNowBank

class DiscoverVC: UIViewController {
    let apiManager: PaceAPIManager!
    let categories = [StoreCategoryList]()
    
    init(apiManager: PaceAPIManager){
        self.apiManager = apiManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Discover"
        getcategoryList()
    }
    
    
    private func getcategoryList(){
        apiManager.store_getStoreCategoryList(completion: {
            result, error in
            if let error = error {
                print("DEBUG: failed to get category list: \(error)")
                return
            }

            print(result?.list)
            
        })
    }
    
}
