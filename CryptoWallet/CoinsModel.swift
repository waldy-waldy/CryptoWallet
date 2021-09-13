//
//  CoinsModel.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import Foundation

class CoinsModel {
    var name: String
    var code: String
    var price: Double
    var changes: Double
    
    init(name: String, code: String, price: Double, changes: Double) {
        self.name = name
        self.code = code
        self.price = price
        self.changes = changes
    }
}
