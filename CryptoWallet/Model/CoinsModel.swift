//
//  CoinsModel.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import Foundation

//ALL COINS

class CoinsModel {
    var name: String
    var code: String
    var price: Double
    var changes: Double
    var website: String?
    var twitter: String?
    
    init(name: String, code: String, price: Double, changes: Double, website: String?, twitter: String?) {
        self.name = name
        self.code = code
        self.price = price
        self.changes = changes
        self.website = website
        self.twitter = twitter
    }
    
    init() {
        self.name = ""
        self.code = ""
        self.price = 0.00
        self.changes = 0.00
        self.website = ""
        self.twitter = ""
    }
}

//MY COINS IN WALLET

class MyCoinsModel {
    var name: String
    var code: String
    var price: Double
    var value: Double
    
    init(name: String, code: String, price: Double, value: Double) {
        self.name = name
        self.code = code
        self.price = price
        self.value = value
    }
}

//IN WALLET COINS

class InwalletModel {
    var code: String
    var value: Double
    
    init(code: String, value: Double) {
        self.code = code
        self.value = value
    }
}

//FAVOURITE COINS

class FavouritesModel {
    var code: String
    
    init(code: String) {
        self.code = code
    }
}

//Coins in wallet
class CoinsInWallet {
    var itemsArray = [MyCoinsModel]()
    var sumOfPrices = 0.00
}

//COINS LIST FOR TABLEVIEW

class CoinsListModel {
    var sectionName: String
    var coinsList: [CoinsModel]?
    
    init(sectionName: String, coinsList: [CoinsModel]){
        self.sectionName = sectionName
        self.coinsList = coinsList
    }
}

class History {
    var historyDate: Date = Date()
    var historyPrice: Double = 0.0
    
    init(date: Date, price: Double) {
        historyDate = date
        historyPrice = price
    }
}
