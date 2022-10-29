//
//  FarmModel.swift
//  SmartFarming
//
//  Created by Eren Bağcı on 16.06.2022.
//

import Foundation
import UIKit

class FarmGlobal {
    
    static let sharedInstance = FarmGlobal()
    
    var farmName = ""
    var plantedVegetables = ""
    var plantedDate = ""
    var harvestDate = ""
    var farmLatitude = ""
    var farmLongitude = ""
    var currentUserEmail = ""
}


class FarmModel {
    
    var farmName: String!
    var plantedVegetables: String?
    var plantedDate: String?
    var harvestDate: String?
    var farmLatitude: String?
    var farmLongitude: String?
    var currentUserEmail: String?
    var documentId: String?

    init(farmName: String? = "", plantedVegetables: String? = "", plantedDate: String? = "", harvestDate: String? = "", farmLatitude: String? = "", farmLongitude: String? = "", currentUserEmail: String? = "", documentId: String? = "") {
        
        self.farmName = farmName
        self.plantedVegetables = plantedVegetables
        self.plantedDate = plantedDate
        self.harvestDate = harvestDate
        self.farmLatitude = farmLatitude
        self.farmLongitude = farmLongitude
        self.currentUserEmail = currentUserEmail
        self.documentId = documentId
    }
}
