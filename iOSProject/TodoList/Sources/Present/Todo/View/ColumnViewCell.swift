//
//  CardView.swift
//  TodoList
//
//  Created by seongha shin on 2022/04/04.
//

import Foundation
import UIKit

class ColumnViewCell: UITableViewCell {
    let cellBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray4
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        attribute()
        layout()
    }
    
    private func attribute() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func layout() {
        self.addSubview(cellBackgroundView)
        self.addSubview(titleLabel)
        self.addSubview(bodyLabel)
        self.addSubview(captionLabel)
        
        NSLayoutConstraint.activate([
            cellBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            cellBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            cellBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            bodyLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            
            captionLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            captionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            captionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            
            cellBackgroundView.bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 16),
            self.bottomAnchor.constraint(equalTo: cellBackgroundView.bottomAnchor, constant: 16)
        ])
    }
    
    func setCard(_ card: Card) {
        self.titleLabel.text = card.title
        self.bodyLabel.text = card.body
        self.captionLabel.text = card.caption
    }
}
