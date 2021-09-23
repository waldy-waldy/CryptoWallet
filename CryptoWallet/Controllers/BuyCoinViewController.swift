//
//  BuyCoinViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/15/21.
//

import UIKit

class BuyCoinViewController: UIViewController, UITextFieldDelegate {

    //OUTLETS
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var changeType: UISegmentedControl!
    @IBOutlet weak var valueTextEdit: UITextField!
    @IBOutlet weak var coinCodeLabel: UILabel!
    @IBOutlet weak var coinDollarLabel: UILabel!
    
    //VARIABLES
    
    var codeCoin = ""
    var rateCOin = 0.00
    var isDollars = false
    let formatter = NumberFormatter()
    let formatter2 = NumberFormatter()
    var resultValue = Double()
    
    //VIEW
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isDollars = false
        coinCodeLabel.text = codeCoin
        coinDollarLabel.text = "0.00 $"
        valueTextEdit.delegate = self
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        
        formatter2.numberStyle = .decimal
        formatter2.maximumFractionDigits = 6
        formatter2.minimumFractionDigits = 6
        formatter2.decimalSeparator = "."
        formatter2.groupingSeparator = " "
        
        balanceLabel.text = String(formatter.string(from: NSNumber(value: Database().getBalance()))!)
    }
    
    //TEXTFIELD
    
    @IBAction func endTyping(_ sender: Any) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func changingText(_ sender: Any) {
        if (isDollars == true) {
            if (valueTextEdit.text?.count != 0) {
                if ((valueTextEdit.text?.starts(with: ".")) == true) {
                    valueTextEdit.text = "0" + valueTextEdit.text!
                }
                resultValue = Double(valueTextEdit.text!)! / rateCOin
                let number = NSNumber(value: resultValue)
                coinDollarLabel.text = String(formatter2.string(from: number)!) + " " + codeCoin
            }
            else {
                coinDollarLabel.text = "0.00 " + codeCoin
            }
        } else {
            
            if (valueTextEdit.text?.count != 0) {
                if ((valueTextEdit.text?.starts(with: ".")) == true) {
                    valueTextEdit.text = "0" + valueTextEdit.text!
                }
                resultValue = (Double(valueTextEdit.text!) ?? 0.00) * rateCOin
                let number = NSNumber(value: resultValue)
                coinDollarLabel.text = formatter.string(from: number)! + " $"
            }
            else {
                coinDollarLabel.text = "0.00 " + "$"
            }
        }
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
        if isDollars == true {
            if arrayOfString.count == 2 {
                if arrayOfString[1].count > 2 {
                    isTwoCharAfterDough = false
                }
            }
        }
        
        return allowedCharacterSet.isSuperset(of: typedCharacterSet) && isOneDough && isTwoCharAfterDough
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //BUTTONS
    
    @IBAction func buyButtonDidTap(_ sender: Any) {
        let balance = Database().getBalance()
        var price = 0.00
        if (valueTextEdit.text?.count != 0){
            if (changeType.selectedSegmentIndex == 0) {
                price = Double(valueTextEdit.text!)!
            }
            else {
                price = resultValue
            }
            if (price <= balance) {
                Database().updateBalance(cost: price)
                Database().addToWallet(code: codeCoin, value: price)
                navigationController?.popViewController(animated: true)
            }
            else {
                let dialogMessage = UIAlertController(title: NSLocalizedString("Sorry", comment: ""), message: NSLocalizedString("You don't have enough money on your card!", comment: ""), preferredStyle: .alert)
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func BackButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //CHANGE SELL TYPE
    
    @IBAction func changedType(_ sender: Any) {
        if (changeType.selectedSegmentIndex == 0) {
            isDollars = false
            coinCodeLabel.text = codeCoin
            coinDollarLabel.text = "0.00 $"
            valueTextEdit.text = ""
        }
        else {
            isDollars = true
            coinCodeLabel.text = "$"
            coinDollarLabel.text = codeCoin
            valueTextEdit.text = ""
        }
    }
    
}
