// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public class UIAutoloadingNibView: UIView {

    private var contentView: UIView!
    private var contentViewIsLoaded = false

    public convenience init() {
        self.init(frame: .zero)
        loadContentViewIfNeeded()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        loadContentViewIfNeeded()
    }

    public override func layoutSubviews() {
        loadContentViewIfNeeded()
        super.layoutSubviews()
        contentView.frame = bounds
    }

    private func loadContentViewIfNeeded() {
        guard !contentViewIsLoaded else { return }

        backgroundColor = .clear
        isOpaque = false

        let nibName = stringType(self)
        let bundle = Bundle.forObject(self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        contentView = nib.instantiate(withOwner: self).first as? UIView
        contentView.frame = bounds
        contentView.backgroundColor = .clear
        contentView.isOpaque = false
        addSubview(contentView)

        contentViewIsLoaded = true
    }

}
