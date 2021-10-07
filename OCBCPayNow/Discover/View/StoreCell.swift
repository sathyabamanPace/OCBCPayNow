//
//  StoreCell.swift
//  OCBCPayNow
//
//  Created by admin on 7/10/21.
//
import UIKit

class StoreCell: UICollectionViewCell {
    
    static let reuseIdentifer = "store-item-cell-reuse-identifier"
    let storeImageView = UIImageView()
    let categoryName : UILabel = {
       let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .black
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        storeImageView.layer.cornerRadius = 10
        storeImageView.layer.borderColor = UIColor.black.cgColor
        storeImageView.layer.borderWidth = 0.2
        storeImageView.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withImageName name: String, title: String = "") {
        storeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(storeImageView)
        
        NSLayoutConstraint.activate([
            storeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            storeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            storeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            storeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        contentView.addSubview(categoryName)
        categoryName.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
        
        storeImageView.image = UIImage(named: name)
        categoryName.text = title
    }
    
    func configure(withImage image: UIImage, title: String = "") {
        storeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(storeImageView)
        
        NSLayoutConstraint.activate([
            storeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            storeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            storeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            storeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        contentView.addSubview(categoryName)
        categoryName.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
        
        storeImageView.image = image
        categoryName.text = title
    }
}


