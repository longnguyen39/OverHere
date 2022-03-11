//
//  PictureCell.swift
//  OverHere
//
//  Created by Long Nguyen on 1/10/22.
//

import UIKit
import SDWebImage

class PictureCell: UITableViewCell {
    
    var photoInfo = Picture(dictionary: [:]) {
        didSet {
            displayInfo()
        }
    }
    
    private var pictureURL: URL? {
        return URL(string: photoInfo.imageUrl)
    }
    
//MARK: - Components
    
    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.tintColor = .yellow.withAlphaComponent(0.87)
        iv.image = UIImage(systemName: "mappin.circle.fill")
        
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.text = "Home Home"
        lb.numberOfLines = 1
        lb.textColor = .green
        
        return lb
    }()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.text = "June 17, 2020"
        lb.numberOfLines = 1
        lb.textColor = .lightGray
        
        return lb
    }()
    
    private let arrowIndicator: UIImageView = {
        let iv = UIImageView() //we dont need contentMode here
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .green
        iv.clipsToBounds = true
        
        return iv
    }()
    
//MARK: - View Scenes

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .black
        
        addSubview(photoView)
        photoView.anchor(left: leftAnchor, paddingLeft: 8, width: 60, height: 80) //rowHeight is 88 (adjust in LibraryVC) - dimension is 60
        photoView.layer.cornerRadius = 8
        photoView.centerY(inView: self)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .leading //anchor to the left
        addSubview(stackView)
        stackView.anchor(left: photoView.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8)
        stackView.centerY(inView: photoView)
        
        addSubview(arrowIndicator)
        arrowIndicator.anchor(right: rightAnchor, paddingRight: 12, width: 24, height: 24)
        arrowIndicator.layer.cornerRadius = 24/2
        arrowIndicator.centerY(inView: photoView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    private func displayInfo() {
        titleLabel.text = photoInfo.title
        dateLabel.text = photoInfo.date
        photoView.sd_setImage(with: pictureURL)
    }

}
