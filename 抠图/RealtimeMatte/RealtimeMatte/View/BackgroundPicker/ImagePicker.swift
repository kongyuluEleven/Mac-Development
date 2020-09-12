//
//  ImagePicker.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import UIKit

class ImagePicker: UIView {
    
    fileprivate let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var showSelectionBorder: Bool = false
    
    var dataProvider: ImageDataProvider? {
        didSet {
            imageCollectionView.reloadData()
        }
    }
    
    var onSelect: ((UIImage) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    func setupLayout(itemSize: CGSize, direction: UICollectionView.ScrollDirection) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.scrollDirection = direction
        switch direction {
        case .horizontal:
            layout.minimumInteritemSpacing = 10.0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        default:
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
        
        imageCollectionView.setCollectionViewLayout(layout, animated: false)
        imageCollectionView.collectionViewLayout.invalidateLayout()
        imageCollectionView.reloadData()
    }
    
    private func initialSetup() {
        imageCollectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: "ImagePickerCell")
        imageCollectionView.bounces = true
        imageCollectionView.alwaysBounceVertical = true
        imageCollectionView.alwaysBounceHorizontal = true
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        addSubview(imageCollectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageCollectionView.frame = bounds
    }
    
    func selectItem(at indexPath: IndexPath) {
        imageCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        collectionView(imageCollectionView, didSelectItemAt: indexPath)
    }
}

extension ImagePicker: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider?.numberOfImages() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath) as! ImageCollectionCell
        cell.showSelectionBorder = showSelectionBorder
        cell.image = dataProvider?.image(at: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = dataProvider?.image(at: indexPath.row) else {
            print("Load image at index: \(indexPath.row) failed")
            return
        }
        onSelect?(image)
    }
}
