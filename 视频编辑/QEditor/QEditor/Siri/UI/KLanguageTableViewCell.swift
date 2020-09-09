//
//  KLanguageTableViewCell.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/9.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class KLanguageTableViewCell: UITableViewCell {

    public var language: OSSVoiceEnum? {
        didSet {
            imageView?.image = language?.flag
            textLabel?.text = language?.title
            detailTextLabel?.text = language?.rawValue
        }
    }

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.masksToBounds = true
        imageView?.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        textLabel?.text = ""
        detailTextLabel?.text = ""
        imageView?.image = nil
    }

}
