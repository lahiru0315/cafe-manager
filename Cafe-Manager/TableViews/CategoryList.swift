//
//  CategoryList.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/4/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseFirestore
class CategoryList: UITableView, UITableViewDelegate, UITableViewDataSource {
    var categories: [(id: String, name: String)] = []
    var parentContext:UIViewController!
    
    let db = Firestore.firestore()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catergoryCell")!
        cell.frame = cell.frame.inset(by: UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10))
        let text = cell.contentView.subviews[0] as! UILabel
        text.text = categories[indexPath.row].name
        return cell
    }
    
    func setDragDelete(index:Int)->[UIContextualAction]{
        let closeAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let alert = UIAlertController(title: "Are you sure", message: "Deleting a category will result in all products under category '\(self.categories[index].name)' will classified as unknown products, recreating the category won't undo this effect.Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes remove", style: .destructive, handler: { action in
                self.db.collection("category").document(self.categories[index].id).delete()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.parentContext.present(alert,animated: true)
            success(true)
        })
        closeAction.backgroundColor = .red
        return [closeAction]
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: setDragDelete(index: indexPath.row))
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: setDragDelete(index: indexPath.row))
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
