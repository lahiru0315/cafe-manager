//
//  OrderMoreDetails.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseFirestore
class OrderMoreDetails: UIViewController {

    @IBOutlet weak var buttonStatus: UIButton!
    @IBOutlet weak var statusDescription: UILabel!
    @IBOutlet weak var itemList: OrderItemList!
    var orderDetails : OrderStatus!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonStatus.setTitle(StaticInfoManager.statusMeaning[orderDetails.status], for: .normal)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StaticInfoManager.dateTimeFormat

        let difference = Calendar.current.dateComponents([.minute], from: dateFormatter.date(from: orderDetails.date!)!, to: Date())
        
        statusDescription.text = "\(difference.minute!) min"
        buttonStatus.addTarget(self, action: #selector(onStatusTapped(sender:)), for: .touchUpInside)
        loadOrderItems()
        // Do any additional setup after loading the view.
    }
    func loadOrderItems(){
     //   (document!.data()?["items"] ?? []) as! [[String:Any]]
        db.collection("ordersList").document(orderDetails.databaseID!).getDocument(completion: {document,err in
            let data  = document!.data()!["items"]  as! [[String:Any]]
            
            let orderItemList:[OrderItemInfo] = data.map({
                OrderItemInfo(foodName: $0["foodName"] as! String,
                    quantity: $0["quantity"] as! Int,
                    originalPrice:  $0["unitPrice"] as! Int)
            })
            self.itemList.data = orderItemList
            self.itemList.reloadData()
        })
    }
    @IBAction func onMakePhoneCall(_ sender: Any) {
        if orderDetails.phoneNumber == nil{
        AlertPopup(self).infoPop(title: "Missing phoneNumber", body: "This customer has not provided any phone number yet")
        }else{
            guard let number = URL(string: "tel://" + orderDetails.phoneNumber!) else { return }
            UIApplication.shared.open(number)
        }
    }
    @objc func onStatusTapped(sender:UIButton){
        let updatableStatus = [1,2,4]
        if updatableStatus.contains(orderDetails.status){
            orderDetails.status += 1
            var uploadingData :[String:Any] = ["status":orderDetails.status]
            if orderDetails.status == 5{
                uploadingData["date"] = StaticInfoManager.getDateString()
            }
            db.collection("ordersList").document(orderDetails.databaseID!).updateData(uploadingData)
            buttonStatus.setTitle(StaticInfoManager.statusMeaning[orderDetails.status], for: .normal)
            if orderDetails.status == 5{
                navigationController?.popViewController(animated: true)
            }
        }
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
