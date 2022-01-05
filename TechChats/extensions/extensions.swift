//
//  extensions.swift
//  TechChats
//
//  Created by administrator on 05/01/2022.
//

import Foundation

extension Dictionary {
    subscript(i:Int) -> (key:Key, value:Value){
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}
