//
//  NoteCollectionViewCell.swift
//  JZToolkit
//
//  Created by Jordan Zucker on 2/15/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
    let nameLabel: UILabel
    let dateLabel: UILabel
    let stackView: UIStackView
    
    override required init(frame: CGRect) {
        self.nameLabel = UILabel(frame: .zero)
        self.dateLabel = UILabel(frame: .zero)
        self.stackView = UIStackView(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(stackView)
        stackView.sizeAndCenter(to: contentView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(dateLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ update: NoteCellUpdate) {
//        textLabel?.text = update.name!
//        detailTextLabel?.text = "\(update.creationDate!)"
        nameLabel.text = update.name
        dateLabel.text = "\(update.creationDate!)"
        setNeedsLayout()
    }
    
}
