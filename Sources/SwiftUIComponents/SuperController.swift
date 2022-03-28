//
//  File.swift
//  
//
//  Created by Fabrizio Boco on 3/26/22.
//

import Foundation

enum ControllerType: Codable {
    case menu
    case list
}

public class SuperController: Codable {
    var type: ControllerType
    
    init(type: ControllerType) {
        self.type = type
    }
}
