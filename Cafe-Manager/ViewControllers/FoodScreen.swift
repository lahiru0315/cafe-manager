//
//  FoodScreen.swift
//  FoodCafe
//
//  Created by Lahiru on 2/23/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import Firebase
class FoodScreen: UIViewController {
    @IBOutlet weak var foodList: FoodList!

    let db = Firestore.firestore()
    let imageStore = Storage.storage()
    var rootNavigator:UINavigationController!
    var isDataLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundleID =  Bundle.main.bundleIdentifier
        print("bundleID \(bundleID)")
        if isDataLoaded{
            let rootController = tabBarController as! StoreRootController
            foodList.categories = rootController.catergories
            foodList.data = rootController.foodData
        }
        foodList.onItemSelected = {data in
            let foodDetailScreen = self.storyboard!.instantiateViewController(identifier: "foodDetailScreen") as! FullFoodDetailScreen
            foodDetailScreen.foodDetail = data
            let backButton = UIBarButtonItem()
                   backButton.title = "Food List"
            self.tabBarController?.tabBarController?.navigationItem.backBarButtonItem = backButton
            self.rootNavigator.pushViewController(foodDetailScreen, animated: true)
        }
    }
  
    


}


