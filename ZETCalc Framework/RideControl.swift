//
//  RideControl.swift
//  ZETCalc Framework
//
//  Created by Domagoj Boros on 14/04/2019.
//  Copyright © 2019 Domagoj Boros. All rights reserved.
//

import UIKit

final public class RideControl: UIControl {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setup(price: UInt, duration: UInt, fontSize: CGFloat) {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        label.text = "\(price)kn \(duration)min"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: label.superview!.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: label.superview!.centerYAnchor),
        ])
    }
    
    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.alpha = self.isHighlighted ? 0.5 : 1.0
            }
        }
    }
}
