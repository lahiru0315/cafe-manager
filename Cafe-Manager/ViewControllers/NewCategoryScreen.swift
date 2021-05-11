//
//  NewCategoryScreen.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/7/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseFirestore
class NewCategoryScreen: UIViewController {
    
    @IBOutlet weak var categoryNameTxt: UITextField!
    @IBOutlet weak var categoryList: CategoryList!
    var didDataLoaded = false
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameTxt.addTarget(self, action: #selector(clearTextField(sender:)), for: .editingDidBegin)
        categoryList.parentContext = self
        if didDataLoaded{
            categoryList.categories = (tabBarController as! StoreRootController).catergories
        }
        

        // Do any additional setup after loading the view.
    }
    @objc func clearTextField(sender:UITextField){
        sender.text = ""
    }
    @IBAction func onCategoryAdded(_ sender: Any) {
        let alert = AlertPopup(self)
        if categoryNameTxt.text?.count == 0{
            return alert.infoPop(title: "Missing name", body: "Please enter a unique category name")
        }
        if categoryNameTxt.text == StaticInfoManager.unknownCategory{
            return alert.infoPop(title: "Invalid name", body: "You cannot add a category with name '\(StaticInfoManager.unknownCategory)' as it is predefined")
        }
        addNewCategory(name: categoryNameTxt.text!,alert:alert)
    }
    func addNewCategory(name:String,alert:AlertPopup){
        db.collection("category").whereField("name", isEqualTo: name).limit(to: 1).getDocuments(completion: {
            data,error in
            if (data?.documents ?? []).count > 0{
                alert.infoPop(title: "Name already exist", body: "Category already exist,please choose a different name")
                return
            }
            var ref:DocumentReference?
            ref = self.db.collection("category").addDocument(data: ["name":name],completion: nil)
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
