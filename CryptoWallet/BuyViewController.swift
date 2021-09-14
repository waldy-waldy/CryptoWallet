//
//  BuyViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/14/21.
//

import UIKit

class BuyViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var changeType: UISegmentedControl!
    @IBOutlet weak var valueTextEdit: UITextField!
    @IBOutlet weak var coinCodeLabel: UILabel!
    @IBOutlet weak var coinDollarLabel: UILabel!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var codeCoin = ""
    var rateCOin = 0.00
    var buyValue = 0.00
    var isDollars = false
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        getCardBalance()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowedCharacters = "0123456789."
            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
            let typedCharacterSet = CharacterSet(charactersIn: string)
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let arrayOfString = newString.components(separatedBy: ".")
            
            var isOneDough = true
            var isTwoCharAfterDough = true
            
            if arrayOfString.count > 2 {
                isOneDough = false
            }
            if arrayOfString.count == 2 {
                if arrayOfString[1].count > 2 {
                    isTwoCharAfterDough = false
                }
            }
            
            return allowedCharacterSet.isSuperset(of: typedCharacterSet) && isOneDough && isTwoCharAfterDough
        }
    
    @IBAction func changeText(_ sender: Any) {
        if (isDollars == true) {
            var resultValue = Double()
            if (valueTextEdit.text?.count != 0) {
                if ((valueTextEdit.text?.starts(with: ".")) == true) {
                    valueTextEdit.text = "0" + valueTextEdit.text!
                }
                resultValue = Double(valueTextEdit.text!)! / rateCOin
                let number = NSNumber(value: resultValue)
                coinDollarLabel.text = String(formatter.string(from: number)!) + " " + codeCoin
            }
            else {
                coinDollarLabel.text = "0.00 " + codeCoin
            }
        } else {
            var resultValue = Double()
            if (valueTextEdit.text?.count != 0) {
                if ((valueTextEdit.text?.starts(with: ".")) == true) {
                    valueTextEdit.text = "0" + valueTextEdit.text!
                }
                resultValue = Double(valueTextEdit.text!)! * rateCOin
                let number = NSNumber(value: resultValue)
                coinDollarLabel.text = String(formatter.string(from: number)!) + " " + codeCoin
            }
            else {
                coinDollarLabel.text = "0.00 " + codeCoin
            }
        }
    }
    
    @IBAction func typeChanged(_ sender: Any) {
        if (changeType.selectedSegmentIndex == 0) {
            isDollars = false
            coinCodeLabel.text = codeCoin
            coinDollarLabel.text = "$"
        }
        else {
            isDollars = true
            coinCodeLabel.text = "$"
            coinDollarLabel.text = codeCoin
        }
    }
    
    @IBAction func BackButtonDidTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func vuyButtonDidTap(_ sender: Any) {
        
    }
    
    func getCardBalance() {
        
    }
}
