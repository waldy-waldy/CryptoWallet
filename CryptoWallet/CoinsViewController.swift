//
//  CoinsViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import UIKit
import Alamofire

class CoinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //OUTLETS
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //VARIABLES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imageCache = NSCache<NSString, UIImage>()
    let starturl = "https://cryptoicon-api.vercel.app/api/icon"
    //let starturl = "https://cryptoicons.org/api/icon/"
    //let endurl = "/40"
    var coinsArray = [CoinsModel]()
    
    //TABLE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CoinsCell = tableView.dequeueReusableCell(withIdentifier: "coinsCell", for: indexPath) as! CoinsCell
        
        let coinsModelTemp = coinsArray[indexPath.row]
        cell.codeLabel.text = coinsModelTemp.code
        cell.nameLabel.text = coinsModelTemp.name
            cell.priceLabel.text = "$ " + String(coinsModelTemp.price)
        cell.changeLabel.text = String(coinsModelTemp.changes) + " %"
        cell.changeLabel.layer.masksToBounds = true
        cell.changeLabel.layer.cornerRadius = 10.0
        cell.changeLabel.backgroundColor = coinsModelTemp.changes < 0 ? UIColor(named: "ValueDown") : UIColor(named: "ValueUp")
        
        var stringUrl = URL(string: starturl)!
        stringUrl.appendPathComponent(coinsModelTemp.code.lowercased())
        //stringUrl.appendPathComponent(endurl)
        let url = URLRequest(url: stringUrl as URL)
        
        if let image = self.imageCache.object(forKey: coinsModelTemp.code as NSString) {
            cell.iconImageView.image = image
        } else {
            AF.request(url).response { response in
                switch response.result {
                case .success(let value) :
                    if let data = value {
                        let img = UIImage(data: data)
                        self.imageCache.setObject(img! as UIImage, forKey: coinsModelTemp.code as NSString)
                        if (coinsModelTemp.code == cell.codeLabel.text) {
                            cell.iconImageView.image = img
                        }
                    } else {
                        cell.iconImageView.image = UIImage(systemName: "bitcoinsign.circle")
                    }
                case .failure(let error) :
                    print(error)
                }
            }
        }
        
        return cell
    }
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topButton.layer.cornerRadius = 15.0
        sortButton.layer.cornerRadius = 15.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        getAllCoins()
    }
    
    //CORE DATA
    
    func getAllCoins() {
        do {
            var tmpCoinsArray = [CoinsEntity]()
            tmpCoinsArray = try context.fetch(CoinsEntity.fetchRequest())
            for item in tmpCoinsArray {
                coinsArray.append(CoinsModel(name: item.name!, code: item.code!, price: item.price, changes: item.changes))
            }
        }
        catch {
            context.rollback()
        }
    }
    
}
