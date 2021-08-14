// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UITableView {

    // MARK: - Separators

    func hideSeparatorForEmptyCells() {
        tableFooterView = UIView()
    }

    // MARK: - Cells, headers, and footers

    func registerCell<Cell: UITableViewCell>(_ cellType: Cell.Type) {
        register(cellType, forCellReuseIdentifier: fullStringType(cellType))
    }

    func registerHeaderFooter<View: UIView>(_ viewType: View.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: fullStringType(viewType))
    }

    func dequeueCell<Cell: UITableViewCell>(_ cellType: Cell.Type, forIndexPath indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: fullStringType(cellType), for: indexPath) as! Cell
    }

}
