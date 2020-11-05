// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveRewards
import BraveUI
import BraveShared
import Shared

private let log = Logger.rewardsLogger

class BraveRewardsViewController: UIViewController, Themeable, PopoverContentComponent {
    let tab: Tab
    let rewards: BraveRewards
    let legacyWallet: BraveLedger?
    var rewardsTransferTapped: (() -> Void)?
    
    private var ledgerObserver: LedgerObserver?
    private var publisher: PublisherInfo? {
        didSet {
            rewardsView.publisherView.isHidden = publisher?.status != .verified
            rewardsView.publisherView.hostLabel.text = publisher?.displayName
        }
    }
    
    init(tab: Tab, rewards: BraveRewards, legacyWallet: BraveLedger?) {
        self.tab = tab
        self.rewards = rewards
        self.legacyWallet = legacyWallet
        
        super.init(nibName: nil, bundle: nil)
        
        let observer = LedgerObserver(ledger: rewards.ledger)
        rewards.ledger.add(observer)
        ledgerObserver = observer
        
        observer.fetchedPanelPublisher = { [weak self] publisher, tabId in
            guard let self = self else { return }
            if tabId == tab.rewardsId {
                self.publisher = publisher
            }
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    private var rewardsView: BraveRewardsView {
        view as! BraveRewardsView // swiftlint:disable:this force_cast
    }
    
    override func loadView() {
        view = BraveRewardsView()
        applyTheme(Theme.of(nil))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                applyTheme(Theme.of(nil))
            }
        }
    }
    
    func applyTheme(_ theme: Theme) {
        rewardsView.applyTheme(theme)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewards.ledger.fetchPromotions(nil)
        
        if let url = tab.url, !url.isLocal {
            rewards.ledger.fetchPublisherActivity(from: url, faviconURL: nil, publisherBlob: nil, tabId: UInt64(tab.rewardsId))
        } else {
            rewardsView.publisherView.isHidden = true
        }
        
        rewardsView.rewardsToggle.isOn = rewards.isEnabled
        
        if !rewards.isEnabled {
            rewardsView.supportedCountView.isHidden = true
        }
        
        rewardsView.legacyWalletTransferButton.isHidden = true
        if let legacyWallet = legacyWallet {
            legacyWallet.transferrableAmount({ [weak self] total in
                guard let self = self else { return }
                if total > 0 {
                    self.rewardsView.legacyWalletTransferButton.isHidden = false
                }
            })
        }
        
        rewards.ledger.listAutoContributePublishers { [weak self] list in
            guard let self = self else { return }
            self.rewardsView.supportedCountView.countLabel.text = "\(list.count)"
        }
        
        rewardsView.publisherView.hostLabel.text = publisher?.displayName
        if let url = tab.url {
            rewardsView.publisherView.faviconImageView.loadFavicon(for: url)
        } else {
            rewardsView.publisherView.faviconImageView.isHidden = true
        }
        rewardsView.subtitleLabel.text = rewards.isEnabled ? Strings.Rewards.enabledBody : Strings.Rewards.disabledBody
        rewardsView.rewardsToggle.addTarget(self, action: #selector(rewardsToggleValueChanged), for: .valueChanged)
        rewardsView.legacyWalletTransferButton.addTarget(self, action: #selector(tappedRewardsTransfer), for: .touchUpInside)
        
        view.snp.makeConstraints {
            $0.width.equalTo(360)
            $0.height.equalTo(rewardsView)
        }
    }
    
    // MARK: - Actions
    
    private var isCreatingWallet: Bool = false
    @objc private func rewardsToggleValueChanged() {
        let isOn = rewardsView.rewardsToggle.isOn
        rewards.isEnabled = isOn
        rewardsView.subtitleLabel.text = isOn ? Strings.Rewards.enabledBody : Strings.Rewards.disabledBody
        if rewardsView.rewardsToggle.isOn {
            rewardsView.supportedCountView.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.beginFromCurrentState]) { [self] in
            rewardsView.supportedCountView.isHidden = !rewardsView.rewardsToggle.isOn
            rewardsView.supportedCountView.alpha = rewardsView.rewardsToggle.isOn ? 1 : 0
        }
    }
    
    @objc private func tappedRewardsTransfer() {
        rewardsTransferTapped?()
    }
}