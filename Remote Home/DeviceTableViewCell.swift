//
//  DeviceTableViewCell.swift
//  Remote Home
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/02/16.
//  Copyright © 2016 Leonardo Vinicius Kaminski Ferreira. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceStatus: UILabel!
    @IBOutlet weak var deviceStatusColorView: UIView!
    @IBOutlet weak var deviceOperationMode: UILabel!
    @IBOutlet weak var deviceOperationColorView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let color = deviceStatusColorView.backgroundColor
        let color2 = deviceOperationColorView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            deviceStatusColorView.backgroundColor = color
            deviceOperationColorView.backgroundColor = color2
        }
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let color = deviceStatusColorView.backgroundColor
        let color2 = deviceOperationColorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if(highlighted) {
            deviceStatusColorView.backgroundColor = color
            deviceOperationColorView.backgroundColor = color2
        }
    }
    
    
    // MARK: ConfigureCell

    func configureCell(_ name:String, status:String, operation:String, statusColor:UIColor, operationColor:UIColor) {
        deviceName.text = name .capitalized
        if(status == "true") {
            deviceStatus.text = "Ativado"
        } else {
            deviceStatus.text = "Desativado"
        }
        deviceOperationMode.text = operation .capitalized
        deviceStatusColorView.backgroundColor = statusColor
        deviceOperationColorView.backgroundColor = operationColor
    }
    
}
