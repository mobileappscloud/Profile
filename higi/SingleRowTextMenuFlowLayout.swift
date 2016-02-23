//
//  SingleRowTextMenuFlowLayout.swift
//  higi
//
//  Created by Remy Panicker on 1/28/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import UIKit

/// Layout flow for a single row collection view
final class SingleRowTextMenuFlowLayout: UICollectionViewFlowLayout {
    
    static let defaultInset: CGFloat = 5.0
    
    /// This property was added as a workaround to a flaw in Apple's current implementation with the collection view's size which is reported when transitioning to a new size class. The collection view referenced on the `UICollectionViewLayout` object has stale size data as does the `collectionView` parameter passed into the delegate methods. As a workaround, this property was added so that we can keep the flow layout object decoupled from the collection view and still get accurate size data.
    var viewWillTransitionToSize: CGSize = CGSizeZero
    
    override func prepareLayout() {
        let defaultItemHeight: CGFloat = 30.0
        let estimatedWidth: CGFloat = 100.0
        let minimumSpacing: CGFloat = 10.0
        let defaultInset: CGFloat = SingleRowTextMenuFlowLayout.defaultInset
        
        self.estimatedItemSize = CGSize(width: estimatedWidth, height: defaultItemHeight)
        self.scrollDirection = .Horizontal
        self.minimumLineSpacing = minimumSpacing
        self.minimumInteritemSpacing = minimumSpacing
        self.sectionInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)
        self.footerReferenceSize = CGSizeZero
        self.headerReferenceSize = CGSizeZero
    }
}