//
//  MyCoinsViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/15/21.
//

import UIKit
import CoreData
import Alamofire

class MyCoinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //OUTLETS
    
    @IBOutlet weak var allCoinsPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //VARIABLES
    
    let starturl = "https://cryptoicon-api.vercel.app/api/icon"
    var itemsArray = [MyCoinsModel]()
    var sumOfPrices = 0.00
    let formatter = NumberFormatter()
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tmp = Database().getItems()
        sumOfPrices = tmp.sumOfPrices
        itemsArray = tmp.itemsArray
        allCoinsPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: sumOfPrices))!
        tableView.reloadData()
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MyCoinsInfoViewController {
            let tmp = itemsArray[tableView.indexPathForSelectedRow!.row]
            destination.myCoinModel = MyCoinsModel(name: tmp.name, code: tmp.code, price: tmp.price, value: tmp.value)
        }
    }

    //TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyCoinsCell = tableView.dequeueReusableCell(withIdentifier: "myCoins", for: indexPath) as! MyCoinsCell
        
        let coinsModelTemp = itemsArray[indexPath.row]
        cell.nameCoin.text = coinsModelTemp.name
        cell.dollarsPrice.text = String(format: "%.2f", coinsModelTemp.price) + " $"
        cell.coinsPrice.text = String(format: "%.6f", coinsModelTemp.value) + " " + coinsModelTemp.code
        cell.code = coinsModelTemp.code
    
        var stringUrl = URL(string: starturl)!
        stringUrl.appendPathComponent(coinsModelTemp.code.lowercased())
        let url = URLRequest(url: stringUrl as URL)
        
        if let image = imageCache.object(forKey: coinsModelTemp.code as NSString) {
            cell.iconCoin.image = image
        } else {
            AF.request(url).response { response in
                switch response.result {
                case .success(let value) :
                    if let data = value {
                        let img = UIImage(data: data)
                        imageCache.setObject(img! as UIImage, forKey: coinsModelTemp.code as NSString)
                        if (coinsModelTemp.code == cell.code) {
                            cell.iconCoin.image = img
                        }
                    } else {
                        cell.iconCoin.image = UIImage(systemName: "bitcoinsign.circle")
                    }
                case .failure(let error) :
                    print(error)
                }
            }
        }
        
        return cell
    }
    
}
