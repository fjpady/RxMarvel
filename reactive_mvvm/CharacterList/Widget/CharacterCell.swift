//
//  CharacterCell.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell {

    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translate()
        configureView()
    }
    
    private func translate() {
        titleName.text = Localizable.CharacterCell.title.localized
        descriptionName.text = Localizable.CharacterCell.description.localized
    }
    
    private func configureView() {
        self.characterImageView.layer.cornerRadius = 10
        self.characterImageView.clipsToBounds = true
    }
    
    func setCell(_ obj: Character) {
        descriptionName.isHidden = false
        titleLabel.text = obj.name
        
        if obj.resultDescription == "" { descriptionName.isHidden = true }
        descriptionLabel.text = obj.resultDescription
        
        if let image = obj.thumbnail, let url = image.getUrl() {
            characterImageView.load(
                url: url,
                placeholder: UIImage(named: "ic_placeholder")
            )
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
