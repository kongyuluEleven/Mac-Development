//
//  ProductItem.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/7/24.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa
import WSStoreKit

class ProductItemView: NSView {

    var isSelected = false {
        didSet {
            self.display()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        var background_color: NSColor = NSColor.init(srgbRed: 33/255.0, green: 41/255.0, blue: 49/255.0, alpha: 1.0)
        if isSelected {
            background_color = NSColor.black
        }
        background_color.set()
        NSBezierPath.fill(self.bounds)
    }
}

class ProductItem: NSCollectionViewItem {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var priceLabel: NSTextField!
    @IBOutlet weak var buyDateLabel: NSTextField!
    @IBOutlet weak var expiredDateLabel: NSTextField!
    @IBOutlet weak var buyButton: CustomButton!
    var didClickBuyBlock: (() -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buyButton.titleColor = NSColor.textColor
        buyButton.backgroundColor = NSColor.init(srgbRed: 33/255.0, green: 41/255.0, blue: 49/255.0, alpha: 1.0)
    }
    
    override var isSelected: Bool {
        didSet {
            self.buyButton.isHidden = !self.isSelected
            let view = self.view as! ProductItemView
            view.isSelected = self.isSelected
        }
    }

    @IBAction func didClickBuyButton(_ sender: Any) {
        didClickBuyBlock?()
    }
    
    func updateSources(product: Product) {
        print("updateSources:", product.identifier)
        self.titleLabel.stringValue = product.originalProduct.localizedTitle
        self.detailLabel.stringValue = product.originalProduct.localizedDescription
        self.priceLabel.stringValue = product.originalProduct.localizedPrice ?? "0.0"
        
        if product.buyDate?.toString() != nil {
            self.buyDateLabel.stringValue = product.buyDate!.toString()
        } else {
            self.buyDateLabel.stringValue = "_ _ _ _/_ _/_ _/_ _:_ _"
        }
        
        if product.expireDate?.toString() != nil {
            if product.expired {
                self.expiredDateLabel.textColor = NSColor.red
            } else {
                self.expiredDateLabel.textColor = NSColor.systemGray
            }
            self.expiredDateLabel.stringValue = product.expireDate!.toString()
        } else {
            self.expiredDateLabel.textColor = NSColor.systemGray
            self.expiredDateLabel.stringValue = "_ _ _ _/_ _/_ _/_ _:_ _"
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    static let itemIdentifie = NSUserInterfaceItemIdentifier("ProductItem")
}
