import Foundation
import UIKit
class AlertPopup{
    let context:UIViewController
    init(_ context:UIViewController) {
        self.context = context
    }
    //a utility function to show a popup with message
    var lastMessage:String?
    func infoPop(title:String,body:String){
        lastMessage = body
        let alert = UIAlertController(title: title, message:body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        context.present(alert,animated: true)
    }
    
    func connectionChangeAlert(){
        let message = "Network state has changed.Please check your internet connection"
        let alert = UIAlertController(title: "Netowrk status changed", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        context.present(alert,animated: true)
    }
}
