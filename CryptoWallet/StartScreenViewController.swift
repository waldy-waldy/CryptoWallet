//
//  StartScreenViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import UIKit
import Alamofire
import CoreData

class StartScreenViewController: UIViewController {

    //OUTLETS
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!

    //VARIABLES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let stringurl = "https://api.coinstats.app/public/v1/coins"
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rotate()
        takeCoinsList()
        // Do any additional setup after loading the view.
    }
    
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
        
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //API
    
    func takeCoinsList() {
        DispatchQueue.main.async { [self] in
            AF.request(stringurl).responseJSON { [weak self] response in
                switch response.result {
                case .success(let value):
                    if let resp = value as? [String: Any] {
                        let data = (resp["coins"] as? [Any])!
                        clearCoins()
                        for item in data {
                            let str = item as? [String: Any]
                            let stringname = str!["name"] as! String
                            let stringcode = str!["symbol"] as! String
                            let stringprice = str!["price"] as! Double
                            let stringwebsite = str!["websiteUrl"] as? String
                            let stringtwitter = str!["twitterUrl"] as? String
                            let stringchanges = str!["priceChange1d"] as! Double
                            createCoins(newItem: CoinsModel(name: stringname, code: stringcode, price: stringprice, changes: stringchanges, website: stringwebsite, twitter: stringtwitter))
                        }
                        let vc = storyboard?.instantiateViewController(identifier: "MainViewController") as? UITabBarController
                        self!.view.window?.rootViewController = vc
                        self!.view.window?.makeKeyAndVisible()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    //CORE DATA
    
    func clearCoins() {
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
}
