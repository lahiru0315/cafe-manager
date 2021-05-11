//
//  RecieptList.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class RecieptList: UITableView, UITableViewDelegate, UITableViewDataSource {

    var data:[Reciept] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func formaetDate(source:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StaticInfoManager.dateTimeFormat
        let date = dateFormatter.date(from: source)
        dateFormatter.dateFormat = "yyy-MM-dd"
        return dateFormatter.string(from: date!)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecieptCell") as! DailyRecieptCell
        let reciept = data[indexPath.row]
        
        if reciept.isRejected{
            cell.canceledLabel.isHidden = false
        }else{
            cell.canceledLabel.isHidden = true
        }
        cell.date.text = formaetDate(source: reciept.date)
        cell.priceFrequencyList.text = ""
        cell.itemList.text = ""
        for r in reciept.products{
            cell.itemList.text! += "\(r.foodName) x \(r.quantity)\n"
            cell.priceFrequencyList.text! += "Rs \(r.quantity * r.originalPrice)\n"
        }
        cell.onPrintRequested = {
            //let jsonData = try? JSONSerialization.data(withJSONObject: JSONEncoder().encode(reciept), options: .prettyPrinted)
            self.printText(text: self.createTable(tables: [reciept]))
        }
        cell.totalPrice.text = String(reciept.totalCost)
        return cell
    }
    func createTable(tables:[Reciept])->String{
        let headers = "<tr>"+["food Name","quantity","price"].map({"<th>\($0)</th>"}).joined() + "</tr>"
        var html = ""
        for reciept in tables{
            let rows = reciept.products.map({
                let data = [$0.foodName,String($0.quantity),String($0.originalPrice)]
                return data.map({d in "<td>\(d)</td>"}).joined()
            }) as [String]
            let rowContent = rows.map({"<tr>\($0)</tr>"}).joined()
            let dateRow = "<tr><span>\(reciept.date)</span></tr>"
            let table = "<table>\(headers + dateRow + rowContent)</table>"
            html += table
        }
        
        var htmlStyle = createStyleObject(object: ["table"], data: [
            "font-family":"arial, sans-serif",
            "border-collapse":"collapse",
            "width":"100%"
        ])
        htmlStyle += createStyleObject(object: ["td","th","span"], data: [
            "border":"px solid #dddddd",
            "text-align":"right",
            "font-size":"25px",
            "padding":"8px"
        ])
        htmlStyle += createStyleObject(object: ["tr:nth-child(even)"], data: ["background-color":"#dddddd"])
        html = "<html><head><style>\(htmlStyle)</style></head><body>\(html)</body></html>"
        print(html)
        return html
    }
    func createStyleObject(object:[String],data:[String:String])->String{
        let objectContent = data.map({key,value in "\(key):\(value)"}).joined(separator: ";")
        return " \(object.joined(separator: ",")) {\(objectContent)}"
    }
    func printText(text:String){
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.grayscale
        printInfo.jobName = "Order Details"
        printInfo.orientation = .portrait

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = false
            
        let formatter = UIMarkupTextPrintFormatter(markupText: text)
        //formatter.contentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter
        
        printController.present(animated: true, completionHandler: nil)
    }
    func updateData(_ data:[Reciept],_ isOnlySingleItem:Bool = false){
        //if only single items added no need to refresh entire tableView just append at end of the list
        if isOnlySingleItem {
            self.data.append(data[0])
            insertRows(at: [IndexPath(row: data.count - 1, section: 0)], with: .none)
            return
        }
        self.data = data
        reloadData()
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
        delegate = self
        dataSource = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
