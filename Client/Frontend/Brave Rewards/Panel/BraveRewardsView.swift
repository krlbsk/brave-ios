// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveShared
import BraveUI
import Shared

extension BraveRewardsViewController {
    class BraveRewardsView: UIStackView, Themeable {
        
        let rewardsToggle = UISwitch().then {
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }
        private let titleLabel = UILabel().then {
            $0.text = Strings.braveRewardsTitle
            $0.font = .systemFont(ofSize: 20)
        }
        let subtitleLabel = UILabel().then {
            $0.text = Strings.Rewards.disabledBody
            $0.font = .systemFont(ofSize: 12)
        }
        
        let publisherView = BraveRewardsPublisherView()
        let statusView = BraveRewardsStatusView()
        let legacyWalletTransferButton = LegacyWalletTransferButton()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            axis = .vertical
            spacing = 20
            
            isLayoutMarginsRelativeArrangement = true
            layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
            
            addStackViewItems(
                .view(UIStackView().then {
                    $0.axis = .horizontal
                    $0.alignment = .center
                    $0.spacing = 12
                    $0.addStackViewItems(
                        .view(UIStackView().then {
                            $0.axis = .vertical
                            $0.spacing = 4
                            $0.addStackViewItems(
                                .view(titleLabel),
                                .view(subtitleLabel)
                            )
                            $0.setContentHuggingPriority(.required, for: .vertical)
                        }),
                        .view(rewardsToggle)
                    )
                }),
                .view(UIStackView().then {
                    $0.axis = .vertical
                    $0.spacing = 8
                    $0.addStackViewItems(
                        .view(legacyWalletTransferButton),
                        .view(statusView)
                    )
                }),
                .view(publisherView)
            )
        }
        
        @available(*, unavailable)
        required init(coder: NSCoder) {
            fatalError()
        }
        
        func applyTheme(_ theme: Theme) {
            let isDark = theme.isDark
            titleLabel.textColor = isDark ? UIColor.white : UIColor.black
            subtitleLabel.textColor = isDark ? UIColor.lightGray : UIColor.gray
            publisherView.applyTheme(theme)
            statusView.applyTheme(theme)
            legacyWalletTransferButton.applyTheme(theme)
            backgroundColor = theme.isDark ? UIColor(rgb: 0x17171f) : UIColor.white
        }
    }
}
