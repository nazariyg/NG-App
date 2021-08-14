// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UICollectionView {

    // MARK: - Cells and supplementary views

    func registerCell<Cell: UICollectionViewCell>(_ cellType: Cell.Type) {
        register(cellType, forCellWithReuseIdentifier: fullStringType(cellType))
    }

    func registerHeader<View: UICollectionReusableView>(_ viewType: View.Type) {
        register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: fullStringType(viewType))
    }

    func registerFooter<View: UICollectionReusableView>(_ viewType: View.Type) {
        register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: fullStringType(viewType))
    }

    func dequeueCell<Cell: UICollectionViewCell>(_ cellType: Cell.Type, forIndexPath indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withReuseIdentifier: fullStringType(cellType), for: indexPath) as! Cell
    }

    func dequeueHeader<View: UICollectionReusableView>(_ viewType: View.Type, forIndexPath indexPath: IndexPath) -> View {
        return
            dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: fullStringType(viewType), for: indexPath) as! View
    }

    func dequeueFooter<View: UICollectionReusableView>(_ viewType: View.Type, forIndexPath indexPath: IndexPath) -> View {
        return
            dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: fullStringType(viewType), for: indexPath) as! View
    }

}
