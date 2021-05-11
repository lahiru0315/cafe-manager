//
//  NewProductScreen.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import Firebase
class NewProductScreen: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var setAsItemCheck: UISwitch!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var discount: UITextField!
    
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    var alert:AlertPopup!
    var categories: [(id: String, name: String)]!
    var foccusedTextfield:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        alert = AlertPopup(self)
        foodImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFoodImageTapped(_:))))
        addBeginEditFieldsCallbacks(fields: [productName,productDescription,productPrice,discount])
        
        discount.addTarget(self, action: #selector(onFinishEditingDiscount(sender:)), for: .editingDidEnd)
        productPrice.addTarget(self, action: #selector(onFinishEnteringCost(sender:)), for: .editingDidEnd)
        
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.backgroundColor = .white
        category.inputView = categoryPicker
        category.addTarget(self, action: #selector(disableTyping(sender:)), for: .editingChanged)
        category.addTarget(self, action: #selector(enableTyping(sender:)), for: .editingDidEnd)
        category.addTarget(self, action: #selector(onCatergoryEditingBegin(sender:)), for: .editingDidBegin)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolbar.setItems([
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(customView: UITextView()),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onFinishSelectingCatergory(sender:))),
                          UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelCategorySelection(sender:)))
        ], animated: true)
        category.inputAccessoryView = toolbar
        // Do any additional setup after loading the view.
    }
    func addBeginEditFieldsCallbacks(fields:[UITextField]){
        for field in fields{
            field.addTarget(self, action: #selector(onBeginEditingFields(sender:)), for: .editingDidBegin)
        }
    }
    @objc func onBeginEditingFields(sender:UITextField){
        foccusedTextfield = sender
    }
    @objc func onFinishEnteringCost(sender:UITextField){
        if sender.text == nil || sender.text == ""{
            return
        }
        if Int(sender.text!) ==  nil{
            sender.text = ""
            alert.infoPop(title: "Invalid cost", body: "You should specify a number for cost")
        }
    }
    
    @objc func onFinishEditingDiscount(sender:UITextField){
        if let text = sender.text{
            let alert = AlertPopup(self)
            if let discountValue = Int(text){
                if discountValue < 0 || discountValue > 100{
                    alert.infoPop(title: "Invalid discount value", body: "Please enter a valid discount value!")
                }else{
                    return sender.text = text
                }
            }else{
                alert.infoPop(title: "Invalid Discount", body: "discount must be a number!")
            }
            sender.text = nil
        }
    }
    @objc func onCatergoryEditingBegin(sender:Any){
        if categories.count == 0{
            alert.infoPop(title: "No category", body: "You first need add a category first")
        }
    }
    @objc func cancelCategorySelection(sender:Any){
        category.endEditing(true)
    }
    @objc func onFinishSelectingCatergory(sender:Any){
        let selectedIndex = (category.inputView as! UIPickerView).selectedRow(inComponent: 0)
        category.text = categories[selectedIndex].name
        category.endEditing(true)
    }
    @objc func disableTyping(sender:UITextField){
        sender.text = nil
        sender.isUserInteractionEnabled = false
    }
    @objc func enableTyping(sender:UITextField){
        sender.isUserInteractionEnabled = true
    }
    @IBAction func onProductAdding(_ sender: Any) {
        if checkIfEmpty(fields: [productName,productDescription,productPrice,category,discount]){
            return
        }
        if foodImage.tag == 2{
            alert.infoPop(title: "No image", body: "Please select an image for the food item. Tap on the image to sslect")
            return
        }
        let selectedCategoryIndex = (category.inputView as! UIPickerView).selectedRow(inComponent: 0)
        var foodDetail = FoodDetail(image: resizeImage(image: foodImage.image!, targetSize:CGSize(width: 200, height: 200)),
                   title: productName.text!, foodDescription: productDescription.text!,
                   cost: Int(productPrice.text!)!, phoneNumber: "dummy", type: categories[selectedCategoryIndex].id)
        if (discount.text ?? "").count > 0 {
            foodDetail.promotion = Int(discount.text!)!
        }
        foodDetail.availability = setAsItemCheck.isOn
        var ref:DocumentReference?
        var mappingData:[String:Any] = [
            "title": foodDetail.title,
            "description": foodDetail.foodDescription!,
            "promotion": foodDetail.promotion,
            "cost": foodDetail.cost,
            "phoneNumber": foodDetail.phoneNumber!,
            "category":foodDetail.type
        ]
        if !foodDetail.availability{
            mappingData["availability"] = false
        }
        ref = db.collection("Foods").addDocument(data: mappingData, completion: {error in
            if error == nil{
                self.storage.reference(withPath: "foods/\(ref!.documentID).jpg").putData(foodDetail.image!.jpegData(compressionQuality: 1.0)!,metadata: nil,completion: {metaData,error in
                    if error == nil{
                        let rootController = (self.tabBarController! as! StoreRootController)
                        rootController.retrieveNewlyAddedFood(docID: ref!.documentID, image: foodDetail.image!)
                        self.tabBarController?.selectedIndex = 0
                    }else{
                        print(error!)
                    }
                })
            }
        })
        
    }
    func checkIfEmpty(fields:[UITextField]) -> Bool{
        let fieldsEmptyCount = fields.filter({($0.text?.count == 0) }).count
        if fieldsEmptyCount > 0 {
            AlertPopup(self).infoPop(title: "Fields Empty", body: "\(fieldsEmptyCount) fields are empty!")
            return true
        }
        return false
    }
    func captureImage(isCamera:Bool){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = isCamera ? .camera : .photoLibrary
        imagePickerController.modalPresentationStyle = .fullScreen
        
        present(imagePickerController,animated: true)
    }
    @objc func onFoodImageTapped(_: Any){
        if foccusedTextfield != nil{
            foccusedTextfield!.endEditing(true)
            foccusedTextfield = nil
            return
        }
        let prompt = UIAlertController(title: "Choose Method", message: "Choose a method to captaure image to food item", preferredStyle: .actionSheet)
        prompt.addAction(UIAlertAction(title: "By Camera", style: .default, handler: {action in
            self.captureImage(isCamera: true)
        }))
        prompt.addAction(UIAlertAction(title: "From gallery",style: .default, handler: { action in
            self.captureImage(isCamera: false)
        }))
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
            prompt.dismiss(animated: true, completion: nil)
        }))
        present(prompt,animated: true)
    }
    
    //this function is called user finished selecting an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as! UIImage //retrieve the image
        foodImage.image = image
        foodImage.tag = 0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
extension NewProductScreen : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categories[row].name
    }
    
    
}
