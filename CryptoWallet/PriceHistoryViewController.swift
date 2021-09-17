//
//  PriceHistoryViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/16/21.
//

import UIKit
import Alamofire

class PriceHistoryViewController: UIViewController {

    @IBOutlet weak var changeType: UISegmentedControl!
    
    var coinName = ""
    var pricesArray = [Double]()
    var datesArray = [Date]()
    let startUrl = "https://api.coincap.io/v2/assest/"
    let endUrl = "/history?interval=h1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getCoinInfo(name: coinName.lowercased().replacingOccurrences(of: " ", with: "-"), type: "d")
        
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.navigationItem.leftBarButtonItem?.title = "Back"
        self.navigationItem.title = coinName
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BackgroundColor")]
        navigationController?.navigationBar.tintColor = UIColor(named: "BackgroundColor")
        // Do any additional setup after loading the view.
    }
    
    func getCoinInfo(name: String, type: String) {
        DispatchQueue.main.async { [self] in
            var stringUrl = URL(string: startUrl + name + endUrl)!
            print(stringUrl)
            AF.request(stringUrl).responseJSON { [weak self] response in
                switch response.result {
                case .success(let value):
                    print(value)
                    if let resp = value as? [String: Any] {
                        let data = (resp["data"] as? [Any])!
                        for item in data {
                            let str = item as? [String: Any]
                            let stringprice = str!["priceUsd"] as! Double
                            let stringdate = str!["date"] as! Date
                            print(stringdate)
                            print(stringprice)
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                }
            }
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
