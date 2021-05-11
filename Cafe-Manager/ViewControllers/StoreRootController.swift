//
//  StoreRootControllerViewController.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/7/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import Firebase
class StoreRootController: UITabBarController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var catergories : [(id:String,name:String)] = []
    var foodData:[FoodDetail] = []
    var foodDataFirstimeLoaded = false
    var alert:AlertPopup!
    override func viewDidLoad() {
        super.viewDidLoad()
        alert = AlertPopup(self)
        loadCategories()
        // Do any additional setup after loading the view.
    }
    func loadCategories(){
        db.collection("category").addSnapshotListener({snapshot,err in
            self.catergories = (snapshot?.documents ?? []).map({
                (id: $0.documentID,name: $0.data()["name"] as! String)
            })
            let foodScreen = (self.viewControllers![0] as! FoodScreen)
            if foodScreen.isViewLoaded{
                foodScreen.foodList.categories = self.catergories
                foodScreen.foodList.reloadData()
            }
            
            let newCategoryScreen = (self.viewControllers![1] as! NewCategoryScreen)
            
            if newCategoryScreen.isViewLoaded{
                newCategoryScreen.categoryList.categories = self.catergories
                newCategoryScreen.categoryList.reloadData()
            }else{
                newCategoryScreen.didDataLoaded = true
            }
            
            let newProductScreen = (self.viewControllers![2] as! NewProductScreen)
            newProductScreen.categories = self.catergories
            
        })
        if !foodDataFirstimeLoaded{
            loadData()
        }
    }
    
    func refreshFoodList(){
        let foodScreen = (viewControllers![0] as! FoodScreen)
        if foodScreen.isViewLoaded{
            foodScreen.foodList.data = foodData
            foodScreen.foodList.updateData(foodData)
        }else{
            foodScreen.isDataLoaded = true
        }
    }
    func postLoadFoodImage(position:Int,image:UIImage?){
        let foodScreen = (viewControllers![0] as! FoodScreen)
        if foodScreen.isViewLoaded{
            foodScreen.foodList.provideImage(index: position, newImage: image)
        }else{
            foodScreen.foodList.data[position].image = image
        }
    }
    func retrieveNewlyAddedFood(docID:String,image:UIImage){
        db.collection("Foods").document(docID).getDocument(completion: {data,err in
            var foodModel = self.populateDataToModel(doc: data!)
            foodModel.image = image
            self.foodData.append(foodModel)
            self.loadData()
        })
    }
    func populateDataToModel(doc:DocumentSnapshot)->FoodDetail{
        let food = doc.data()!
        var foodDetail = FoodDetail(
            id:doc.documentID,
            image: nil,
            title: food["title"] as! String,
            foodDescription: food["description"] as? String,
            promotion:(food["promotion"] as? Int) ?? 0,
            cost: food["cost"] as! Int,
            phoneNumber: food["phoneNumber"] as? String,
            type: self.catergories.first(where: {$0.id == (food["category"] as! String)})?.name ?? StaticInfoManager.unknownCategory,
            availability: (food["availability"] as? Bool) ?? true
        )
        if(food.keys.contains("promotion")){
            foodDetail.promotion = food["promotion"] as! Int
        }
        return foodDetail
    }
    func loadData(){
        db.collection("Foods").getDocuments(completion:{snapshot,err in
            if(err != nil){
                print("food error "+err!.localizedDescription)
                self.alert.infoPop(title: "Error loading food list", body: "An error occured loading food details")
            }
            //each docuemnt reflect detail about a single food item..
            self.foodData = []
            for (index,document) in (snapshot?.documents ?? []).enumerated(){
                 //single food instance..
                //populating date into data model....
                let foodDetail = self.populateDataToModel(doc: document)
                //if contains a promotion field then add the promotion
                
                
              
                
                /*images are loaded afterwards the food details are loaded allowing user to view partially loaded data.
                 this is callback for image loading and later refresh the relvant cell when image is available.The image is identified by food ID - docuemnt id*/
                self.storage.reference(withPath: "foods/\(document.documentID).jpg").getData(maxSize: 1 * 1024 * 1024, completion: {data,imageErr in
                    
                    if(imageErr != nil){
                        
                        switch StorageErrorCode(rawValue: imageErr!._code) {
                        case .objectNotFound:
                            
                            //if the image is not available in the database then display a default image
                            self.postLoadFoodImage(position: index,image: #imageLiteral(resourceName: "emptyFood"))
                    
                        default:
                            self.alert.infoPop(title: "Error loading image", body: "There was an error in loading food image")
                            print(imageErr)
                        }
                    }else{
                        //if no error then update the revant cell against the index to with newly fetched food picture
                        self.postLoadFoodImage(position: index, image: UIImage(data: data!))
                    }
                })
                self.foodData.append(foodDetail)
            }
            /*
             the food catergory List only updates when 'all' catergory selected means param 'catergory' is nil
            */
            //finally refresh the food list
            if !self.foodDataFirstimeLoaded{
                self.foodDataFirstimeLoaded = true
            }
            self.refreshFoodList()
            })
        
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
