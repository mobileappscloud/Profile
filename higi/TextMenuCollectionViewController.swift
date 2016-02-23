//
//  TextCollectionViewController.swift
//  higi
//
//  Created by Remy Panicker on 12/3/15.
//  Copyright © 2015 higi, LLC. All rights reserved.
//

import UIKit

/// Collection view controller for use with a single row of text-based cells.
final class TextCollectionViewController: UICollectionViewController {
    
    /// Object which configures a collection view.
    var collectionViewConfigurator: TextMenuCollectionViewConfiguration?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewConfigurator?.configureCollectionView(self.collectionView)
    }
}

// MARK: - Configuration Protocol

/**
 *  Configuration protocol for collection view.
 */
protocol TextMenuCollectionViewConfiguration {
    
    /**
     Configure a collection view before usage. This method is called when the collection view controller is loaded.
     
     - parameter collectionView: Collection view to be displayed.
     */
    func configureCollectionView(collectionView: UICollectionView?)
}

// MARK: Default implementation

// Default implementation for collection view configuration.
extension TextMenuCollectionViewConfiguration {
    
    func configureCollectionView(collectionView: UICollectionView?) {
        guard let collectionView = collectionView else { return }
        collectionView.registerNib(UINib(nibName: "TextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TextCollectionViewCell.cellReuseIdentifier)
    }
}
