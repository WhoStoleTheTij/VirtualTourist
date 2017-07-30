//
//  MessageHelper.swift
//  VirtualTourist
//
//  Created by Richard H on 30/07/2017.
//  Copyright © 2017 Richard H. All rights reserved.
//

import Foundation
import UIKit


class MessageHelper{
    
    
    //Mark: display an error message to the user
    func showUserErrorMessage(message:String, view: UIViewController){
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .default)
        alert.addAction(okAction)
        view.present(alert, animated:true, completion:nil)
    }
    
    
    
    
}
