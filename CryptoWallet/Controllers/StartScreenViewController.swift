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
    
    let stringurl = "https://api.coinstats.app/public/v1/coins"
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rotate()
        takeCoinsList()
        // Do any additional setup after loading the view.
    }
    
    //LOGO
    
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    //API
    
    func takeCoinsList() {
        DispatchQueue.main.async { [self] in
            AF.request(stringurl).responseJSON { [weak self] response in
                switch response.result {
                case .success(let value):
                    if let resp = value as? [String: Any] {
                        let data = (resp["coins"] as? [Any])!
                        Database().clearCoinsEntity()
                        for item in data {
                            let str = item as? [String: Any]
                            let stringname = str!["name"] as! String
                            let stringcode = str!["symbol"] as! String
                            let stringprice = str!["price"] as! Double
                            let stringwebsite = str!["websiteUrl"] as? String
                            let stringtwitter = str!["twitterUrl"] as? String
                            let stringchanges = str!["priceChange1d"] as! Double
                            Database().createCoins(newItem: CoinsModel(name: stringname, code: stringcode, price: stringprice, changes: stringchanges, website: stringwebsite, twitter: stringtwitter))
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
    
    // FAILED API REQUEST
    
    func showAlert() {
        let dialogMessage = UIAlertController(title: NSLocalizedString("Oooops", comment: ""), message: NSLocalizedString("Something going wrong", comment: ""), preferredStyle: .alert)
        let refresh = UIAlertAction(title: NSLocalizedString("Try again", comment: ""), style: .default, handler: tryAgain)
        var str = ""
        if (Database().getItemsCount() > 0) {
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
    
    // DIALOG BUTTONS
    
    func tryAgain(alert: UIAlertAction!) {
        takeCoinsList()
    }
    
    func exitOrCancel(alert: UIAlertAction!) {
        if (Database().getItemsCount() > 0) {
            let vc = storyboard?.instantiateViewController(identifier: "MainViewController") as? UITabBarController
            self.view.window?.rootViewController = vc
            self.view.window?.makeKeyAndVisible()
        }
        else {
            exit(0)
        }
    }
    
}
