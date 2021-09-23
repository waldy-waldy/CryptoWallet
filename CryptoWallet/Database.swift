//
//  File.swift
//  CryptoWallet
//
//  Created by neoviso on 9/22/21.
//

import Foundation
import UIKit
import CoreData

protocol DatabaseProtocol {
    
    func getCurrentPrice(name: String) -> Double
    func addToBalance(value: Double)
    func subFromWallet(code: String, value: Double)
    func removeFromWallet(code: String)
    func clearCoins()
    func getItems() -> CoinsInWallet
    func getBalance() -> Double
    func updateBalance(cost: Double)
    func addToWallet(code: String, value: Double)
    func getCoinByCode(code: String) -> CoinsModel
    func checkFavourite(code: String) -> Bool
    func addFavouriteCoin(code: String)
    func deleteItem(itemCode: String)
    func getItemsCount() -> Int
    func createCoins(newItem: CoinsModel)
    func clearCoinsEntity()
    func getAllCoins() -> [CoinsModel]
    func getAllFavouritesCoins() -> [CoinsModel]
    
}

class Database {
    
    fileprivate let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let shared = DatabaseProtocol()
    
    func getCurrentPrice(name: String) -> Double {
        var pr = 0.00
        do {
            let items = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            pr = items.first(where: { $0.name == name})!.price
        }
        catch {
            context.rollback()
        }
        return pr
    }
    
    func addToBalance(value: Double) {
        do {
            let items = try context.fetch(BalanceEntity.fetchRequest()) as! [BalanceEntity]
            if items.count > 0 {
                let tmpBalance = items.first
                tmpBalance!.value = tmpBalance!.value + value
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
        }
        catch {
            context.rollback()
        }
    }
    
    func removeFromWallet(code: String) {
        do {
            let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            let item = items.first(where: { $0.code == code })
            context.delete(item!)
            do {
                try context.save()
            }
            catch {
                context.rollback()
            }
        }
        catch {
            
        }
    }
    
    func subFromWallet(code: String, value: Double) {
        do {
            let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            let item = items.first(where: { $0.code == code })
            item!.value = item!.value - value
            do {
                try context.save()
            }
            catch {
                context.rollback()
            }
        }
        catch {
            
        }
    }
    
    func clearCoins() {
        do {
            let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            for item in items {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    func getItems() -> CoinsInWallet {
        let temp = CoinsInWallet()
        do {
            temp.sumOfPrices = 0.00
            let itemsCoins = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            let itemWallet = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            for item in itemWallet {
                let tmp = itemsCoins.first(where: { $0.code == item.code })
                if tmp != nil {
                    let pr = item.value * tmp!.price
                    temp.sumOfPrices += pr
                    let tempCoin = MyCoinsModel(name: tmp!.name!, code: item.code!, price: pr, value: item.value)
                    temp.itemsArray.append(tempCoin)
                }
            }
        }
        catch {
            
        }
        return temp
    }
    
    func getBalance() -> Double {
        var returnValue = 0.00
        do {
            let items = try context.fetch(BalanceEntity.fetchRequest()) as! [BalanceEntity]
            returnValue = items.first!.value
        }
        catch {
            
        }
        return returnValue
    }
    
    func updateBalance(cost: Double) {
        do {
            let items = try context.fetch(BalanceEntity.fetchRequest()) as! [BalanceEntity]
            if items.count > 0 {
                let tmpBalance = items.first
                tmpBalance!.value = tmpBalance!.value - cost
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
        }
        catch {
            
        }
    }
    
    func addToWallet(code: String, value: Double) {
        do {
            let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            let item = items.first(where: { $0.code == code })
            if item != nil {
                item!.value += value
            }
            else {
                let tmp = InwalletEntity(context: context)
                tmp.code = code
                tmp.value = value
            }
            do {
                try context.save()
            }
            catch {
                context.rollback()
            }
        }
        catch {
            
        }
    }
    
    func getCoinByCode(code: String) -> CoinsModel {
        var returnCoin = CoinsModel()
        do {
            let items = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            let tmpCoin = items.first(where: {$0.code == code})!
            returnCoin = CoinsModel(name: tmpCoin.name!, code: tmpCoin.code!, price: tmpCoin.price, changes: tmpCoin.changes, website: tmpCoin.website, twitter: tmpCoin.twitter)
        }
        catch {
            context.rollback()
        }
        return returnCoin
    }
    
    func checkFavourite(code: String) -> Bool {
        var check = false
        do {
            let items = try context.fetch(FavouritesEntity.fetchRequest()) as! [FavouritesEntity]
            let tmpCoin = items.first(where: {$0.code == code})
            if tmpCoin != nil {
                check = true
            }
        }
        catch {
            context.rollback()
        }
        return check
    }
    
    func addFavouriteCoin(code: String) {
        let tmpCoin = FavouritesEntity(context: context)
        tmpCoin.code = code
        
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    
    func deleteItem(itemCode: String) {
        do {
            let items = try context.fetch(FavouritesEntity.fetchRequest()) as! [FavouritesEntity]
            let tmpCoin = items.first(where: {$0.code == itemCode})!
        
            context.delete(tmpCoin)
            
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        } catch {
            context.rollback()
        }
    }
    
    func getItemsCount() -> Int {
        var c = 0
        do {
            let items = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            c = items.count
        }
        catch {
            context.rollback()
        }
        return c
    }
    
    func createCoins(newItem: CoinsModel) {
        let tempItem = CoinsEntity(context: context)
        tempItem.code = newItem.code
        tempItem.name = newItem.name
        tempItem.price = newItem.price
        tempItem.changes = newItem.changes
        tempItem.website = newItem.website
        tempItem.twitter = newItem.twitter
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    func clearCoinsEntity() {
        do {
            let items = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            for item in items {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    func getAllCoins() -> [CoinsModel] {
        var coinsList = [CoinsModel]()
        do {
            var tmpCoinsArray = [CoinsEntity]()
            tmpCoinsArray = try context.fetch(CoinsEntity.fetchRequest())
            for item in tmpCoinsArray {
                coinsList.append(CoinsModel(name: item.name!, code: item.code!, price: item.price, changes: item.changes, website: item.website, twitter: item.twitter))
            }
        }
        catch {
            context.rollback()
        }
        return coinsList
    }
    
    func getAllFavouritesCoins() -> [CoinsModel] {
        var coinsList = [CoinsModel]()
        do {
            var tmpCoinsArray = [FavouritesEntity]()
            tmpCoinsArray = try context.fetch(FavouritesEntity.fetchRequest())
            for item in tmpCoinsArray {
                coinsList.append(getAllCoins().first(where: {$0.code == item.code!})!)
            }
        }
        catch {
            context.rollback()
        }
        return coinsList
    }
    
}
