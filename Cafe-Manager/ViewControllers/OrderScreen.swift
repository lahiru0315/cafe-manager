//
//  OrderScreen.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/4/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation
import AVFoundation
class OrderScreen: UITableViewController {
    let db = Firestore.firestore()
    var orders:[OrderStatus] = []
    let locationService:LocationService = LocationService()
    var player:AVAudioPlayer?
    var userLocationListenerInitialized = false
    var alert:AlertPopup!
    override func viewDidLoad(){
      alert = AlertPopup(self)
      loadOrders()
    }
    func loadOrders(){
        db.collection("ordersList").whereField("status",isLessThanOrEqualTo:4).addSnapshotListener({query,error in
            if error != nil{
                print(error)
            }
            let orderList:[OrderStatus] = (query?.documents ?? []).map({
                let data = $0.data()
                let orderStatus = OrderStatus(databaseID: $0.documentID,
                                              orderID:data["id"] as! Int,
                                              customerName: data["customerName"] as? String,
                                              status: data["status"] as! Int,
                                              customerID: data["uid"] as! String,
                                              phoneNumber: data["phoneNumber"] as? String,
                                              date:data["date"] as? String
                                              )
                return orderStatus
            })
            if !self.userLocationListenerInitialized{
                //add the snaphot listener when orders are populated for the first time...
                self.checkForArrivingStatus()
                self.userLocationListenerInitialized = false
            }
            self.orders = orderList
            self.getSectionHeadings()
            self.tableView.reloadData()
            
        })
    }
   
    func checkForArrivingStatus(){
        
        db.collection("userLocation").addSnapshotListener({documents,error in
            let locations = (documents?.documents ?? []).map({
                UserLocation(location: $0.data()["location"] as! GeoPoint, uid: $0.documentID)
            })
            self.locationService.requestLocation()
            self.locationService.onLocationRecived = { shopLocation in
                var shouldPlaySound = false
                for location in locations{
                    var orderToBeUpadated = self.orders.first(where: {$0.customerID == location.uid && $0.status == 3})
                    if orderToBeUpadated == nil{
                        continue // go to next order
                    }
                    
                    let distance = shopLocation?.distance(from: CLLocation(latitude: location.location.latitude, longitude: location.location.latitude)) ?? 100
                    print("distance \(distance)")
                    if distance <= 10{
                            orderToBeUpadated!.status += 1
                        self.db.collection("ordersList").document(orderToBeUpadated!.databaseID!).updateData(["status":orderToBeUpadated!.status],completion: { error in
                            if error == nil{
                                shouldPlaySound = true
                            }
                        })
                    }
                }
                if shouldPlaySound{
                    self.playSound()
                }
            }
            
        })
        
    }
    
    func playSound() {
        let pathToSound = Bundle.main.path(forResource: "notification", ofType: "mp3")!
        let url = URL(fileURLWithPath: pathToSound)
        do {
           // try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            //try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
           // let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:*/
           
            player = try AVAudioPlayer(contentsOf: url)
            player!.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    var sectionHeadings:[(status:Int,frequesncy:Int)] = []
    func getSectionHeadings(){
        
        var sections:[(status:Int,frequesncy:Int)] = []
        
        for status in orders.map({$0.status}){
            let index = sections.firstIndex(where: {$0.status == status})
            if index != nil {
                sections[index!].frequesncy += 1
            }
            else{
                sections.append((status,1))
            }
        }
        sectionHeadings = sections.sorted(by: {$0.status < $1.status})
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if orders.count == 0{
            return nil
        }
        let entry = sectionHeadings[section]
        return "\(StaticInfoManager.statusMeaning[entry.status]!) (\(entry.frequesncy))"
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return orders.count == 0 ? 1 : sectionHeadings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count == 0 ? 1 : sectionHeadings[section].frequesncy
        //return sectionHeadings.map({key,value in value})[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderStatusCell", for: indexPath) as! OrderStatusCell
        if orders.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "noOrdersPoster",for: indexPath)
        }
        let filteredData = orders.filter({$0.status == sectionHeadings [indexPath.section].status})
        let orderInfo = filteredData[indexPath.row]
        
        cell.orderID.text = String(orderInfo.orderID)
        cell.customerName.text = orderInfo.customerName
        cell.statusContainer.setTitle(StaticInfoManager.statusMeaning [orderInfo.status], for: .normal)
        cell.onOrderSelected = {
            self.onOrderSelected(source: orderInfo)
        }
        if filteredData[indexPath.row].status == 1{
            cell.secondaryButton.setTitle("Accept", for: .normal)
            
            cell.statusContainer.setTitle("Reject", for: .normal)
            cell.buttonContainer.addSubview(cell.statusContainer)
            //cell.statusContainer.tag = (0..<indexPath.section).map({tableView.numberOfRows(inSection: $0)}).reduce(0, +) + indexPath.row
            var index = 0
            cell.statusContainer.tag = orders.firstIndex(where: {
                if $0.status == 1{
                    if index == indexPath.row{
                        return true
                    }
                    index += 1
                    return false
                }
                return false
            })!
            cell.secondaryButton.tag = cell.statusContainer.tag
            cell.secondaryButton.isHidden = false
            cell.secondaryButton.addTarget(self, action: #selector(onOrderAccepted(sender:)), for: .touchUpInside)
            cell.statusContainer.backgroundColor = .red
            cell.statusContainer.addTarget(self, action: #selector(onOrderRejected(sender:)), for: .touchUpInside)
            
        }else{
            cell.statusContainer.removeTarget(self, action: #selector(onOrderRejected(sender:)), for: .touchUpInside)
            cell.statusContainer.backgroundColor = #colorLiteral(red: 1, green: 0.4706886616, blue: 0.1020977057, alpha: 1)
            cell.secondaryButton.isHidden = true
        }
        // Configure the cell...

        return cell
    }
    @objc func onOrderAccepted(sender:UIButton){
        db.collection("ordersList").document(orders[sender.tag].databaseID!).updateData(["status":2])
    }
    @objc func onOrderRejected(sender:UIButton){
        db.collection("ordersList").document(orders[sender.tag].databaseID!).updateData(["status":6,"date":StaticInfoManager.getDateString()])
    }
    func onOrderSelected(source:OrderStatus){
         let backButton = UIBarButtonItem()
               backButton.title = "\(source.customerName!) (\(source.orderID)"
        tabBarController?.navigationItem.backBarButtonItem = backButton
        let screen = storyboard?.instantiateViewController(identifier: "OrderMoreDetails") as! OrderMoreDetails
        screen.orderDetails = source
        tabBarController?.navigationController?.pushViewController(screen, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
