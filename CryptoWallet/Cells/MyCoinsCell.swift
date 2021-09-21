//
//  MyCoinsCell.swift
//  CryptoWallet
//
//  Created by neoviso on 9/15/21.
//

import UIKit

class MyCoinsCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dollarsPrice: UILabel!
    @IBOutlet weak var coinsPrice: UILabel!
    @IBOutlet weak var nameCoin: UILabel!
    @IBOutlet weak var iconCoin: UIImageView!
    
    var code: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.shadowColor = UIColor(named: "AdditionalCOlor")?.cgColor
        mainView.layer.shadowOpacity = 0.3
        mainView.layer.timeOffset = .zero
        mainView.layer.shadowRadius = 5
        mainView.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
}
