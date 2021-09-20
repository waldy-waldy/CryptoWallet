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
                    else {
                        showAlert()
                    }
                case .failure(let error):
                    showAlert()
                }
            }
        }
    }
    
    func showAlert() {
        let dialogMessage = UIAlertController(title: NSLocalizedString("Oooops", comment: ""), message: NSLocalizedString("Something going wrong", comment: ""), preferredStyle: .alert)
        let refresh = UIAlertAction(title: NSLocalizedString("Try again", comment: ""), style: .default, handler: tryAgain)
        var str = ""
        if (getItemsCount() > 0) {
            str = NSLocalizedString("Continue with old data", comment: "")
        }
        else {
            str = NSLocalizedString("Exit", comment: "")
        }
        let cancel = UIAlertAction(title: str, style: .default, handler: exitOrCancel)
        dialogMessage.addAction(refresh)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func tryAgain(alert: UIAlertAction!) {
        takeCoinsList()
    }
    
    func exitOrCancel(alert: UIAlertAction!) {
        if (getItemsCount() > 0) {
            let vc = storyboard?.instantiateViewController(identifier: "MainViewController") as? UITabBarController
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }
        else {
            exit(0)
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
}
