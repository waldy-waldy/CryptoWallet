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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
    
    let starturl = "https://cryptoicon-api.vercel.app/api/icon"
    var itemsArray = [MyCoinsModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var allCoinsPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var sumOfPrices = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getItems()
        allCoinsPriceLabel.text = "$ " + String(format: "%.2f", sumOfPrices)
        tableView.reloadData()
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
    
    func getItems() {
        do {
            itemsArray.removeAll()
            sumOfPrices = 0.00
            let itemsCoins = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            let itemWallet = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
            for item in itemWallet {
                let tmp = itemsCoins.first(where: { $0.code == item.code })
                if tmp != nil {
                    let pr = item.value * tmp!.price
                    sumOfPrices += pr
                    let tempCoin = MyCoinsModel(name: tmp!.name!, code: item.code!, price: pr, value: item.value)
                    itemsArray.append(tempCoin)
                }
            }
        }
        catch {
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
