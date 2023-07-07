//
//  NotFoundStack.swift
//  Tracker
//
//  Created by Andrey Sysoev on 29.04.2023.
//

import UIKit

final class NotFoundStack: UIStackView {
    private let notFoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Star")
        return imageView
    }()
    
    private let notFoundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    convenience init(label: String) {
        self.init()
        
        notFoundLabel.text = label
        
        setup()
        addSubviews()
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 8
    }
    
    private func addSubviews() {
        addArrangedSubview(notFoundImageView)
        addArrangedSubview(notFoundLabel)
    }
}
