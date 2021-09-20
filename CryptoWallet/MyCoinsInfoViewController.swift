//
//  MyCoinsInfoViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/16/21.
//

import UIKit
import CoreData

class MyCoinsInfoViewController: UIViewController {

    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var coinValue: UILabel!
    @IBOutlet weak var dollarValue: UILabel!
    @IBOutlet weak var sellBtn: UIButton!
    @IBOutlet weak var inwallLabel: UILabel!
    @IBOutlet weak var inwalldollLabel: UILabel!
    @IBOutlet weak var sellAllSwitcher: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        
        navigationController?.navigationBar.tintColor = UIColor(named: "BackgroundColor")
        
        self.navigationItem.title = myCoinModel.name
        
        inwallLabel.text = String(format:"%.6f", myCoinModel.value) + " " + myCoinModel.code
        inwalldollLabel.text = String(format:"%.2f", myCoinModel.price) + " $"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BackgroundColor")]
        
        valueSlider.maximumValue = Float(myCoinModel.value)
        valueSlider.minimumValue = 0
        sellBtn.layer.cornerRadius = 15.0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("History", comment: ""), style: .done, target: self, action: #selector(showPricesHistory(sender:)))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sellSwitched(_ sender: Any) {
        if (sellAllSwitcher.isOn) {
            coinValue.text =  String(format: "%.6f", myCoinModel.value) + " " + myCoinModel.code
            dollarValue.text = String(format: "%.2f", myCoinModel.price) + " $"
            valueSlider.value = valueSlider.maximumValue
            valueSlider.isEnabled = false
            valueSlider.alpha = 0.5
            sellBtn.isEnabled = true
            sellBtn.alpha = 1.0
        }
        else {
            valueSlider.isEnabled = true
            valueSlider.alpha = 1.0
        }
    }
    
    @objc func showPricesHistory(sender: UIBarButtonItem) {
        let vc = (storyboard?.instantiateViewController(identifier: "PriceHistoryViewController"))
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    var myCoinModel = MyCoinsModel(name: "", code: "", price: 0.00, value: 0.00)
    var dbl = 0.00
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func changeSellValue(_ sender: Any) {
        if (valueSlider.value == 0) {
            sellBtn.isEnabled = false
            sellBtn.alpha = 0.5
            coinValue.text = "0.00 " + myCoinModel.code
            dollarValue.text = "0.00 $"
        }
        else {
            sellBtn.isEnabled = true
            sellBtn.alpha = 1.0
            coinValue.text =  String(format: "%.6f", valueSlider.value) + " " + myCoinModel.code
            dbl = myCoinModel.price * Double(valueSlider.value)/myCoinModel.value
            dollarValue.text = String(format: "%.2f", dbl) + " $"
        }
    }
    
    @IBAction func sellBtnDidTap(_ sender: Any) {
        let dialogMessage = UIAlertController(title: NSLocalizedString("Sure?", comment: ""), message: NSLocalizedString("Are you sure that you want to sell it?", comment: ""), preferredStyle: .alert)
        let y = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: sellCoins)
        let n = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil)
        dialogMessage.addAction(y)
        dialogMessage.addAction(n)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func sellCoins(alert: UIAlertAction!) {
        addToBalance(value: dbl)
        removeFromWallet()
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PriceHistoryViewController {
            destination.coinName = myCoinModel.name
            destination.coinCode = myCoinModel.code
        }
    }
    
    func addToBalance(value: Double) {
        do {
            let items = try context.fetch(BalanceEntity.fetchRequest()) as! [BalanceEntity]
            if items.count > 0 {
                let tmpBalance = items.first
                tmpBalance!.value = tmpBalance!.value + value
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
        }
        catch {
            
        }
    }
    
    func removeFromWallet() {
        if (valueSlider.value == valueSlider.maximumValue) {
            do {
                let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
                let item = items.first(where: { $0.code == myCoinModel.code })
                context.delete(item!)
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
            catch {
                
            }
        }
        else {
            do {
                let items = try context.fetch(InwalletEntity.fetchRequest()) as! [InwalletEntity]
                let item = items.first(where: { $0.code == myCoinModel.code })
                item!.value = item!.value - Double(valueSlider.value)
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
            catch {
                
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
