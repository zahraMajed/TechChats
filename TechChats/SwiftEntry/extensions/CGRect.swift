//
//  CGRect.swift
//  TechChats
//
//  Created by Zahra Majed on 18/06/1443 AH.
//

import UIKit

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
