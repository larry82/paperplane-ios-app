//
//  GuideView.swift
//  Sample
//
//  Created by Steven Lin on 2023/6/21.
//

import Foundation
import UIKit

class GuideView: UIView{
    lazy var numberImageView: UIImageView = {
       let v = UIImageView()
        v.contentMode = .scaleAspectFill
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var guideImageView: UIImageView = {
       let v = UIImageView()
        v.contentMode = .scaleAspectFill
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var hintLabel: UILabel = {
       let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 18, weight: .bold)//UIFont(name: "NunitoSans-Regular", size: 18.0)
        v.numberOfLines = 0
        v.textColor = .guideViewTextColor
        v.textAlignment = .center
        
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    init(){
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        addSubview(numberImageView)
        addSubview(guideImageView)
        addSubview(hintLabel)
        
        self.layer.cornerRadius = 55
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            numberImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11),
            numberImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            numberImageView.widthAnchor.constraint(equalToConstant: 32),
            numberImageView.heightAnchor.constraint(equalTo: numberImageView.widthAnchor, multiplier: 32.0/33.0),
            
            hintLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: numberImageView.bottomAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: guideImageView.topAnchor),
            
            guideImageView.widthAnchor.constraint(equalToConstant: 230),
            guideImageView.heightAnchor.constraint(equalTo: guideImageView.widthAnchor, multiplier: 143.0/230.0),
            guideImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            guideImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -13)
        ])
    }
    
    func setContent(status: ScanHintType){
        let rawVal = status.rawValue
        numberImageView.image = UIImage(named: "guideNo\(rawVal)")
        guideImageView.image = UIImage(named: "guideImg\(rawVal)")
        hintLabel.text = status.description
    }
}
