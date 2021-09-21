//
//  coinsSell.swift
//  CryptoWallet
//
//  Created by neoviso on 9/13/21.
//

import UIKit

class CoinsCell: UITableViewCell {

    //OUTLETS
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    //CELL
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = UIImage(systemName: "bitcoinsign.circle")
    }

}
