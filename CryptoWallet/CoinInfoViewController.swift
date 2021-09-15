//
//  CoinInfoViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/14/21.
//

import UIKit
import CoreData
import Alamofire

class CoinInfoViewController: UIViewController {

    //OUTLETS
    
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var changesLabel: PaddingLabel!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var accuracyPriceLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var favouriteImageView: UIImageView!
    
    //VARIABLES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tempCoin = CoinsModel()
    var coinCode = ""
    
    //VIEW
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requestToAPI()
        tempCoin = getCoinByCode(code: coinCode)
        let tmp = checkFavourite(code: tempCoin.code)
        if tmp == false {
            favouriteImageView.image = UIImage(systemName: "heart")
        } else {
            favouriteImageView.image = UIImage(systemName: "heart.fill")
        }
        websiteButton.layer.cornerRadius = 15.0
        twitterButton.layer.cornerRadius = 15.0
        buyButton.layer.cornerRadius = 15.0
        
        coinNameLabel.text = tempCoin.name
        accuracyPriceLabel.text = "$ " + String(tempCoin.price)
        if (tempCoin.website != nil) {
            websiteButton.isHidden = false
        }
        else {
            websiteButton.isHidden = true
        }
        if (tempCoin.twitter != nil) {
            twitterButton.isHidden = false
        }
        else {
            twitterButton.isHidden = true
        }
        if (tempCoin.changes > 0) {
            changesLabel.backgroundColor = UIColor(named: "ValueUp")
            changesLabel.text = "+" + String(tempCoin.changes) + " %"
        }
        else {
            changesLabel.backgroundColor = UIColor(named: "ValueDown")
            changesLabel.text = String(tempCoin.changes) + " %"
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappped(tapGestureRecognizer:)))
        favouriteImageView.isUserInteractionEnabled = true
        favouriteImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTappped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if (tappedImage.image == UIImage(systemName: "heart")) {
            addFavouriteCoin()
            tappedImage.image = UIImage(systemName: "heart.fill")
        }
        else {
            deleteItem(itemCode: coinCode)
            tappedImage.image = UIImage(systemName: "heart")
        }
    }
    
    //API
    
    func requestToAPI() {
        let starturl = "https://cryptoicon-api.vercel.app/api/icon" + coinCode
        var stringUrl = URL(string: starturl)!
        stringUrl.appendPathComponent(coinCode.lowercased())
        //stringUrl.appendPathComponent(endurl)
        let url = URLRequest(url: stringUrl as URL)
        
        if let image = imageCache.object(forKey: coinCode as NSString)
        {
            coinIconImageView.image = image
        } else {
            AF.request(url).response { [self] response in
                switch response.result {
                case .success(let value) :
                    if let data = value {
                        let img = UIImage(data: data)
                        imageCache.setObject(img! as UIImage, forKey: self.coinCode as NSString)
                        self.coinIconImageView.image = img
                    } else {
                        self.coinIconImageView.image = UIImage(systemName: "bitcoinsign.circle")
                    }
                case .failure(let error) :
                    print(error)
                }
            }
        }
    }
    
    @IBAction func buyButtonDidTap(_ sender: Any) {
        performSegue(withIdentifier: "showBuyView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BuyCoinViewController {
            destination.codeCoin = coinCode
            destination.rateCOin = tempCoin.price
        }
    }
    
    //BUTTONS
    
    @IBAction func websiteButtonDidTap(_ sender: Any) {
        if let url = URL(string: tempCoin.website!) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func twitterButtonDidTap(_ sender: Any) {
        if let url = URL(string: tempCoin.twitter!) {
            UIApplication.shared.open(url)
        }
    }
    
    //CORE DATA
    
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
    
    func addFavouriteCoin() {
        let tmpCoin = FavouritesEntity(context: context)
        tmpCoin.code = tempCoin.code
        
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
}
