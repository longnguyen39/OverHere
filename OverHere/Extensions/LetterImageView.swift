//
//  LetterImageView.swift
//  OverHere
//
//  Created by Long Nguyen on 10/31/21.
//

import UIKit

//MARK: - Username letter ImageView

func parameterLetter(nameImg: String, color: UIColor) -> UIImageView {
    let iv = UIImageView()
    let img = UIImage(systemName: nameImg)
    iv.image = img
    iv.tintColor = color
    return iv
}

func userNameLetterIV(userName: String, completion: @escaping(UIImageView) -> Void) {
    if userName.hasPrefix("a") || userName.hasPrefix("A") {
        let iv = parameterLetter(nameImg: "a.circle", color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("b") || userName.hasPrefix("B") {
        let iv = parameterLetter(nameImg: "b.circle", color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("c") || userName.hasPrefix("C") {
        let iv = parameterLetter(nameImg: "c.circle", color: #colorLiteral(red: 0, green: 0.6329114437, blue: 0.9008632302, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("d") || userName.hasPrefix("D") {
        let iv = parameterLetter(nameImg: "d.circle", color: #colorLiteral(red: 0.518465536, green: 0.9899835039, blue: 0.4038765554, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("e") || userName.hasPrefix("E") {
        let iv = parameterLetter(nameImg: "e.circle", color: #colorLiteral(red: 1, green: 0.6550099254, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("f") || userName.hasPrefix("F") {
        let iv = parameterLetter(nameImg: "f.circle", color: #colorLiteral(red: 0.9288668036, green: 0.4526491761, blue: 0.7728531957, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("g") || userName.hasPrefix("G") {
        let iv = parameterLetter(nameImg: "g.circle", color: #colorLiteral(red: 0.9762720466, green: 0, blue: 0.4197714627, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("h") || userName.hasPrefix("H") {
        let iv = parameterLetter(nameImg: "h.circle", color: #colorLiteral(red: 0.9920338988, green: 0.4676517844, blue: 0.3796064258, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("i") || userName.hasPrefix("I") {
        let iv = parameterLetter(nameImg: "i.circle", color: #colorLiteral(red: 0.8626801372, green: 0.8187113404, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("j") || userName.hasPrefix("J") {
        let iv = parameterLetter(nameImg: "j.circle", color: #colorLiteral(red: 0.9317278862, green: 0, blue: 0.823472321, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("k") || userName.hasPrefix("K") {
        let iv = parameterLetter(nameImg: "k.circle", color: #colorLiteral(red: 0.9073595405, green: 0.5200007558, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("l") || userName.hasPrefix("L") {
        let iv = parameterLetter(nameImg: "l.circle", color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("m") || userName.hasPrefix("M") {
        let iv = parameterLetter(nameImg: "m.circle", color: #colorLiteral(red: 0, green: 0.8693534732, blue: 0.709576726, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("n") || userName.hasPrefix("N") {
        let iv = parameterLetter(nameImg: "n.circle", color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("o") || userName.hasPrefix("O") {
        let iv = parameterLetter(nameImg: "o.circle", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("p") || userName.hasPrefix("P") {
        let iv = parameterLetter(nameImg: "p.circle", color: #colorLiteral(red: 0, green: 0.7141841054, blue: 0.7047259212, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("q") || userName.hasPrefix("Q") {
        let iv = parameterLetter(nameImg: "q.circle", color: #colorLiteral(red: 0.9317278862, green: 0.3827327806, blue: 0.5576081628, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("r") || userName.hasPrefix("R") {
        let iv = parameterLetter(nameImg: "r.circle", color: #colorLiteral(red: 0.7945595384, green: 0.9262536168, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("s") || userName.hasPrefix("S") {
        let iv = parameterLetter(nameImg: "s.circle", color: #colorLiteral(red: 0.7021132112, green: 0.6298170686, blue: 0.9672662616, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("t") || userName.hasPrefix("T") {
        let iv = parameterLetter(nameImg: "t.circle", color: #colorLiteral(red: 0.9543228745, green: 0, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("u") || userName.hasPrefix("U") {
        let iv = parameterLetter(nameImg: "u.circle", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("v") || userName.hasPrefix("V") {
        let iv = parameterLetter(nameImg: "v.circle", color: #colorLiteral(red: 0.9075693488, green: 0.5144899487, blue: 0.4638314247, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("w") || userName.hasPrefix("W") {
        let iv = parameterLetter(nameImg: "w.circle", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("x") || userName.hasPrefix("X") {
        let iv = parameterLetter(nameImg: "x.circle", color: #colorLiteral(red: 0, green: 0.9652629495, blue: 0.9244092107, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("y") || userName.hasPrefix("Y") {
        let iv = parameterLetter(nameImg: "y.circle", color: #colorLiteral(red: 0.5522432923, green: 0.8626424074, blue: 0, alpha: 1))
        completion(iv)
    } else if userName.hasPrefix("z") || userName.hasPrefix("Z") {
        let iv = parameterLetter(nameImg: "z.circle", color: #colorLiteral(red: 0.5500158072, green: 0.8626928926, blue: 0.6717638373, alpha: 1))
        completion(iv)
    } else {
        let iv = parameterLetter(nameImg: "questionmark.circle", color: .white)
        completion(iv)
    }
    
    
}
