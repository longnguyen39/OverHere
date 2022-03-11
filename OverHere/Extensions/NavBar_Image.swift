//
//  NavBarExtensions.swift
//  GoChat
//
//  Created by Long Nguyen on 7/30/21.
//

import UIKit

extension UIViewController {
    
    //let's customize the navigation bar
    func configureNavigationBar (title: String, preferLargeTitle: Bool, backgroundColor: UIColor, buttonColor: UIColor, interface: UIUserInterfaceStyle) {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() //just call it
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] //enables us to set our big titleColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] //set titleColor
        appearance.backgroundColor = backgroundColor
        
        //just call it
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance //when you scroll down, the nav bar just shrinks
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //specify what show be showing up on the nav bar
        navigationController?.navigationBar.prefersLargeTitles = preferLargeTitle
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = buttonColor //enables us to set the color for the image or any nav bar button
        navigationController?.navigationBar.isTranslucent = true
        
        //specify the status bar (battery, wifi display) - (and tint color of SearchBar)
        navigationController?.navigationBar.overrideUserInterfaceStyle = interface
        
    }
    
    
}

extension UIImage {
    func resizeImage(to size: CGSize) -> UIImage {
       return UIGraphicsImageRenderer(size: size).image { _ in
           draw(in: CGRect(origin: .zero, size: size))
    }
}}
