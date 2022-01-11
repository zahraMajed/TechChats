//
//  extensions.swift
//  TechChats
//
//  Created by administrator on 05/01/2022.
//

import Foundation
import MessageKit

extension Dictionary {
    subscript(i:Int) -> (key:Key, value:Value){
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}


extension MessageKind {
    var msgKindString: String {
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
