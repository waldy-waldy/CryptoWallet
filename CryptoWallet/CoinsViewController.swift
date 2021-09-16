//
//  CoinsViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import UIKit
import Alamofire
import CoreData

var coinsvc = CoinsViewController()
var imageCache = NSCache<NSString, UIImage>()

class CoinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //OUTLETS
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //VARIABLES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let starturl = "https://cryptoicon-api.vercel.app/api/icon"
    let formatter = NumberFormatter()
    //let starturl = "https://cryptoicons.org/api/icon/"
    //let endurl = "/40"
    var coinsArray = [CoinsListModel(sectionName: NSLocalizedString("Favourites", comment: ""), coinsList: []), CoinsListModel(sectionName: NSLocalizedString("All", comment: ""), coinsList: [])]
    
    //TABLE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinsArray[section].coinsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (coinsArray[section].coinsList!.count > 0) {
            return 40
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor(named: "PrimaryColor")
        
        let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width - 15, height: 40))
        lbl.text = coinsArray[section].sectionName
        lbl.textColor = UIColor(named: "BackgroundColor")
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return coinsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CoinsCell = tableView.dequeueReusableCell(withIdentifier: "coinsCell", for: indexPath) as! CoinsCell
        
        let coinsModelTemp = coinsArray[indexPath.section].coinsList?[indexPath.row]
        cell.codeLabel.text = coinsModelTemp?.code
        cell.nameLabel.text = coinsModelTemp?.name
        cell.priceLabel.text = "$ " + String(formatter.string(from: NSNumber(value: coinsModelTemp!.price))!)
        cell.changeLabel.layer.masksToBounds = true
        cell.changeLabel.layer.cornerRadius = 10.0
        cell.changeLabel.backgroundColor = coinsModelTemp!.changes < 0 ? UIColor(named: "ValueDown") : UIColor(named: "ValueUp")
        cell.changeLabel.text = coinsModelTemp!.changes < 0 ? (String(coinsModelTemp!.changes) + " %") : ("+" + String(coinsModelTemp!.changes) + " %")
        
        var stringUrl = URL(string: starturl)!
        stringUrl.appendPathComponent(coinsModelTemp!.code.lowercased())
        //stringUrl.appendPathComponent(endurl)
        let url = URLRequest(url: stringUrl as URL)
        
        if let image = imageCache.object(forKey: coinsModelTemp!.code as NSString) {
            cell.iconImageView.image = image
        } else {
            AF.request(url).response { response in
                switch response.result {
                case .success(let value) :
                    if let data = value {
                        let img = UIImage(data: data)
                        imageCache.setObject(img! as UIImage, forKey: coinsModelTemp!.code as NSString)
                        if (coinsModelTemp?.code == cell.codeLabel.text) {
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
    
    func clearItems() {
        do {
            let items = try context.fetch(FavouritesEntity.fetchRequest()) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearItems()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        
        topButton.layer.cornerRadius = 15.0
        sortButton.layer.cornerRadius = 15.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    @objc func reloadTable(notification: NSNotification) {
        getAllCoins()
        getAllFavouritesCoins()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllCoins()
        getAllFavouritesCoins()
        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CoinInfoViewController {
            let str = coinsArray[tableView.indexPathForSelectedRow!.section].coinsList![tableView.indexPathForSelectedRow!.row].code
            destination.coinCode = str
        }
    }
    
    //CORE DATA
    
    func getAllCoins() {
        do {
            coinsArray[1].coinsList?.removeAll()
            var tmpCoinsArray = [CoinsEntity]()
            tmpCoinsArray = try context.fetch(CoinsEntity.fetchRequest())
            for item in tmpCoinsArray {
                coinsArray[1].coinsList?.append(CoinsModel(name: item.name!, code: item.code!, price: item.price, changes: item.changes, website: item.website, twitter: item.twitter))
            }
        }
        catch {
            context.rollback()
        }
    }
    
    func getAllFavouritesCoins() {
        do {
            coinsArray[0].coinsList?.removeAll()
            var tmpCoinsArray = [FavouritesEntity]()
            tmpCoinsArray = try context.fetch(FavouritesEntity.fetchRequest())
            for item in tmpCoinsArray {
                coinsArray[0].coinsList?.append((coinsArray[1].coinsList?.first(where: {$0.code == item.code!}))!)
            }
        }
        catch {
            context.rollback()
        }
    }
    
}
