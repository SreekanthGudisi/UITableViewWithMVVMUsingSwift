//
//  SharedInformation.swift
//  TiLaAssignment
//
//  Created by Gudisi, Sreekanth on 15/12/19.
//  Copyright © 2019 Gudisi, Sreekanth. All rights reserved.
//

import Foundation
import UIKit

class GlobalVariableInformation {
    
    private static var globalVariableInformation : GlobalVariableInformation? = nil

    // API Key
    var apiKeyString = "998dbcdf518d47e4be88aff5d19acd9c" // API Key
    var pageSize = 5 //default will get 5 results
    var page = 1
    var totalItems = 0;

    static func instance() -> GlobalVariableInformation {
        if (globalVariableInformation == nil) {
            globalVariableInformation = GlobalVariableInformation()
        }
        return globalVariableInformation!
    }
    
    private init() {
        // Fetch logged in keys
    }
}


