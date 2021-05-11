//
//  AccountScreenViewController.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import Firebase
class AccountScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let db = Firestore.firestore()
    let auth = Auth.auth()
    var storage = Storage.storage()
    var username:String?
    var alert:AlertPopup!
    @IBOutlet weak var overallTotal: UILabel!
    var contactNo:String?
    var data:[Reciept] = []
    @IBOutlet weak var beforeDate: UITextField!
    @IBOutlet weak var toDate: UITextField!
    @IBOutlet weak var billList: RecieptList!
    var currentPhoneNumber:String?
    let dateFormatter = DateFormatter()
    var isOnlySingleItemAdded = false
    let BEGINING_OF_TIME = "from begining"
    func loadData(){
        
        db.collection("ordersList").whereField("status", isGreaterThanOrEqualTo: 5).addSnapshotListener({data,err in
            
            if(err != nil){
                print(err)
                return
            }
            self.data = (data?.documents ?? []).map({
                let dataDictionary = $0.data()
                var reciept = Reciept(date: dataDictionary["date"] as! String, products: [])
                reciept.products = (dataDictionary["items"] as! [[String:Any]]).map({
                    return OrderItemInfo(foodName: $0["foodName"] as! String, quantity: $0["quantity"] as! Int, originalPrice: $0["unitPrice"] as! Int)
                })
                reciept.totalCost = reciept.products.map({$0.quantity * $0.originalPrice}).reduce(0, +)
                if (dataDictionary["status"] as! Int) == 6{
                    reciept.isRejected = true
                }
                return reciept
            })
            self.isOnlySingleItemAdded = ((self.data.count - self.data.count) == 1)
    
            //refresh data based on date filtering
            self.filterData(fromDate: self.beforeDate.text!, toDate: self.toDate.text!)
            })
    }
   
   
    
    //setting the dataTime pick texfields
    //tag 1 - before date
    //tag 3 - after date
    func setupDatePicker(textField:UITextField,tag:Int){
        textField.tag = tag
        
        //setting intial date ...
        textField.text = tag == 2 ? dateFormatter.string(from: Date()) //today date
            : BEGINING_OF_TIME
        
        //setting the tags
        let datePickerView = UIDatePicker()
                   datePickerView.datePickerMode = .date
        datePickerView.tag = tag
        datePickerView.backgroundColor = .white
        if(tag == 2){
            datePickerView.maximumDate = Date()
        }else{
            datePickerView.maximumDate = Date()
        }
        
        //setting the tool bar buttons
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(endEditingDate(sender:)))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        textField.inputView = datePickerView
        
       /*
         setting the secondary button
         before date - the from beging of time
         after date - set for today date
        */
        var secondaryFunctionButton:UIBarButtonItem
        if tag == 1{
            secondaryFunctionButton = UIBarButtonItem(title: "From begining of time", style: .plain, target: self, action: #selector(onSetttingBegingOfTime(sender:)))
        }else{
            secondaryFunctionButton = UIBarButtonItem(title: "Set Today", style: .plain, target: self, action: #selector(onSettingTodayDate(sender:)))
        }
        doneButton.tag = tag
        //setting the toolbar
        let buttonList = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),secondaryFunctionButton,doneButton]
        toolBar.setItems(buttonList, animated: true)

        textField.inputAccessoryView = toolBar
    }
    @objc func onSettingTodayDate(sender:UIBarButtonItem){
        let datePicker = toDate.inputView as! UIDatePicker
        datePicker.date = Date()
        endEditingDate(sender: sender)
    }
    @objc func onSetttingBegingOfTime(sender:UIBarButtonItem){
        beforeDate.text = BEGINING_OF_TIME
        beforeDate.endEditing(true)
        //start refreshing data
        filterData(fromDate: beforeDate.text!, toDate: toDate.text!)
    }
    override func viewDidLoad() {
        alert = AlertPopup(self)
        dateFormatter.dateFormat = StaticInfoManager.dateOnly
        super.viewDidLoad()
        setupDatePicker(textField: beforeDate, tag: 1)
        setupDatePicker(textField: toDate, tag: 2)
        loadData()
    }
    
    //refresh the data in the tableView
    func refreshData(newData:[Reciept]) {
        //updating total cost of all fitered items
        self.overallTotal.text = String(newData.map{$0.totalCost}.reduce(0,+))
        self.billList.updateData(newData,isOnlySingleItemAdded) //indicate that no need to update entire tableView if isOnlySingleItemAdded is true - only just append to end of tableView
        isOnlySingleItemAdded = false
    }
    
    //function to filter the list of reciept by date
    func filterData(fromDate:String,toDate:String){
        let foreignDataFormater = DateFormatter()
        foreignDataFormater.dateFormat = StaticInfoManager.dateTimeFormat
        let filteredData = data.filter{
            /*Stripping the time component from date instnace this is because in example if after date is set today and if recipet has date like today + 8:30 AM then isUpperBoundSatisfied is never satisfied its after the today date.
             isLowerBoundSatisfied - before date condition, always satisfied if from begining of time
             isUpperBoundSatisfied - after date condition
             */
            let timeStrippedDateString = dateFormatter.string(from: foreignDataFormater.date(from: $0.date)!)
            let isLowerBoundSatisfied = (fromDate == BEGINING_OF_TIME) || dateFormatter.date(from: timeStrippedDateString)! >= dateFormatter.date(from: fromDate)!
            let isUpperBoundSatisfied = dateFormatter.date(from: timeStrippedDateString)! <= dateFormatter.date(from: toDate)!
        
            return isLowerBoundSatisfied && isUpperBoundSatisfied
            
        }
        refreshData(newData: filteredData)
    }
    
    @IBAction func onPrintAll(_ sender: Any) {
        billList.printText(text: billList.createTable(tables:data))
    }
    
    @objc func endEditingDate(sender:UIBarButtonItem){
        let focusedField:UITextField = sender.tag == 1 ? beforeDate : toDate
        let focusedFieldDatePicker = focusedField.inputView as! UIDatePicker
        focusedField.endEditing(true)
        
       if sender.tag == 2{
            let beforeDatePicker = beforeDate.inputView as! UIDatePicker
            beforeDatePicker.maximumDate = focusedFieldDatePicker.date
            if beforeDate.text != BEGINING_OF_TIME{
                beforeDate.text = dateFormatter.string(from: beforeDatePicker.date)
            }
       }
        focusedField.text = dateFormatter.string(from: focusedFieldDatePicker.date)
        filterData(fromDate: beforeDate.text!, toDate: toDate.text!)
    }

   
}
