//
//  UIView+Extensions.swift
//  PixelClear
//
//  Created by savana kranth on 01/09/2020.
//  Copyright © 2020 savana kranth. All rights reserved.
//

import UIKit

extension UIView {
    
    func pc_makeViewRounded(_ customRadius: CGFloat = 5, circular: Bool = false) {
        var radius = customRadius
        if circular,
            bounds.size.width == bounds.size.height {
            radius = bounds.size.width/2
        }
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
}
