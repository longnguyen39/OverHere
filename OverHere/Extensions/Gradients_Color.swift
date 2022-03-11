//
//  Gradients.swift
//  GoChat
//
//  Created by Long Nguyen on 8/2/21.
//


import UIKit

let colorLiteral = #colorLiteral(red: 0.3928793073, green: 0.7171890736, blue: 0.1947185397, alpha: 1)
let color6digit = UIColor(rgb: 0xD3F6AA) //for reference

//MARK: - Gradient

extension UIViewController {
    
    func configureGradientLayer (from: NSNumber, to: NSNumber) {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemGreen.cgColor, UIColor.white.cgColor]
        gradient.locations = [from, to] //the gradient works vertically, the marks indicate where the gradient (2 or more colors equally divided) starts and stops. the entire screen is 0 -> 1
        
        //those lines insert the gradient into the view
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
        
    }
    
    
}

//MARK: - Color literal

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
