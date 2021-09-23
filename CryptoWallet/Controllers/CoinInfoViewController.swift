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
    
    @IBOutlet weak var changesLabel: PaddingLabel!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var accuracyPriceLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var coinNameLabel: UILabel!
    
    //VARIABLES
    
    var tempCoin = CoinsModel()
    var coinCode = ""
    
    //VIEW
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func backBtnDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BuyCoinViewController {
            destination.codeCoin = coinCode
            destination.rateCOin = tempCoin.price
        }
        if let dest = segue.destination as? PriceHistoryViewController {
            dest.coinName = tempCoin.name
            dest.coinCode = tempCoin.code
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestToAPI()
        
        tempCoin = Database().getCoinByCode(code: coinCode)
        
        let tmp = Database().checkFavourite(code: tempCoin.code)
        if tmp == false {
            favouriteImageView.image = UIImage(systemName: "heart")
        } else {
            favouriteImageView.image = UIImage(systemName: "heart.fill")
        }
        
        historyBtn.layer.cornerRadius = 20.0
        websiteButton.layer.cornerRadius = 15.0
        twitterButton.layer.cornerRadius = 15.0
        buyButton.layer.cornerRadius = 15.0
        
        coinNameLabel.text = tempCoin.name
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = ". "
        formatter.groupingSeparator = " "
                
        accuracyPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: tempCoin.price))!
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
        changesLabel.layer.masksToBounds = true
        changesLabel.layer.cornerRadius = 20.0
        
        websiteButton.layer.cornerRadius = 20.0
        twitterButton.layer.cornerRadius = 20.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappped(tapGestureRecognizer:)))
        favouriteImageView.isUserInteractionEnabled = true
        favouriteImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // ADD TO FAVOURITE
    
    @objc func imageTappped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if (tappedImage.image == UIImage(systemName: "heart")) {
            Database().addFavouriteCoin(code: tempCoin.code)
            tappedImage.image = UIImage(systemName: "heart.fill")
        }
        else {
            Database().deleteItem(itemCode: coinCode)
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
                        if img != nil {
                            imageCache.setObject(img! as UIImage, forKey: self.coinCode as NSString)
                            self.coinIconImageView.image = img
                        }
                        else {
                            self.coinIconImageView.image = UIImage(systemName: "bitcoinsign.circle")
                        }
                    } else {
                        self.coinIconImageView.image = UIImage(systemName: "bitcoinsign.circle")
                    }
                case .failure(let error) :
                    print(error)
                }
            }
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
    
}
