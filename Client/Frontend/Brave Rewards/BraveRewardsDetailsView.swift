// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveUI

class BraveRewardsPublisherView: UIStackView, Themeable {
    
    let faviconImageView = UIImageView().then {
        $0.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        $0.layer.cornerRadius = 4
        if #available(iOS 13.0, *) {
            $0.layer.cornerCurve = .continuous
        }
        $0.clipsToBounds = true
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    let hostLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20.0)
        $0.textAlignment = .left
    }
    
    let bodyLabel = UILabel().then {
        $0.text = "You are supporting content creators like this one."
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 16)
    }
    
    func applyTheme(_ theme: Theme) {
        hostLabel.textColor = theme.isDark ? .white : .black
        bodyLabel.textColor = theme.isDark ? .white : .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = UIEdgeInsets(equalInset: 16)
        isLayoutMarginsRelativeArrangement = true
        axis = .vertical
        spacing = 12

        addStackViewItems(
            .view(UIStackView(arrangedSubviews: [faviconImageView, hostLabel]).then {
                $0.spacing = 8
                $0.alignment = .center
            }),
            .view(bodyLabel)
        )
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
}
