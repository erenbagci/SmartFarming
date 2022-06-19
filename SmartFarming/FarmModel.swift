//
//  FarmModel.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 16.06.2022.
//

import Foundation
import UIKit

class FarmModel {
    
    static let sharedInstance = FarmModel()
    
    var farmName = ""
    var plantedVegetables = ""
    var plantedDate = ""
    var harvestDate = ""
    var farmLatitude = ""
    var farmLongitude = ""
    var currentUserEmail = ""
}
