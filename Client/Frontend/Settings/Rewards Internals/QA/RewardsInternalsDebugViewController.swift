// Copyright 2020 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Static
import BraveShared
import Shared
import BraveRewards
import BraveRewardsUI

/// A place where all rewards debugging information will live.
class RewardsInternalsDebugViewController: TableViewController {
    
    private let ledger: BraveLedger
    private var internalsInfo: RewardsInternalsInfo?
    private var transferrableTokens: Double = 0.0
    
    init(ledger: BraveLedger) {
        self.ledger = ledger
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
        ledger.rewardsInternalInfo { info in
            self.internalsInfo = info
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.RewardsInternals.title
        
        guard let info = internalsInfo else { return }
        
        let dateFormatter = DateFormatter().then {
            $0.dateStyle = .short
        }
        let batFormatter = NumberFormatter().then {
            $0.minimumIntegerDigits = 1
            $0.minimumFractionDigits = 1
            $0.maximumFractionDigits = 3
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedShare)).then {
            $0.accessibilityLabel = Strings.RewardsInternals.shareInternalsTitle
        }
        
        var sections: [Static.Section] = [
            .init(
                header: .title(Strings.RewardsInternals.walletInfoHeader),
                rows: [
                    Row(text: Strings.RewardsInternals.keyInfoSeed, detailText: "\(info.isKeyInfoSeedValid ? Strings.RewardsInternals.valid : Strings.RewardsInternals.invalid)"),
                    Row(text: Strings.RewardsInternals.walletPaymentID, detailText: info.paymentId, cellClass: SubtitleCell.self),
                    Row(text: Strings.RewardsInternals.walletCreationDate, detailText: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(info.bootStamp))))
                ]
            ),
            .init(
                header: .title(Strings.RewardsInternals.deviceInfoHeader),
                rows: [
                    Row(text: Strings.RewardsInternals.status, detailText: DCDevice.current.isSupported ? Strings.RewardsInternals.supported : Strings.RewardsInternals.notSupported),
                    Row(text: Strings.RewardsInternals.enrollmentState, detailText: DeviceCheckClient.isDeviceEnrolled() ? Strings.RewardsInternals.enrolled : Strings.RewardsInternals.notEnrolled)
                ]
            )
        ]
        
        if let balance = ledger.balance {
            let keyMaps = [
                "anonymous": Strings.RewardsInternals.anonymous,
                "uphold": "Uphold",
                "blinded": "Rewards \(Strings.BAT)"
            ]
            let walletRows = balance.wallets.map { (key, value) -> Row in
                Row(text: keyMaps[key] ?? key, detailText: "\(batFormatter.string(from: value) ?? "0.0") \(Strings.BAT)")
            }
            sections.append(
                .init(
                    header: .title(Strings.RewardsInternals.balanceInfoHeader),
                    rows: [
                        Row(text: Strings.RewardsInternals.totalBalance, detailText: "\(batFormatter.string(from: NSNumber(value: balance.total)) ?? "0.0") \(Strings.BAT)")
                    ] + walletRows
                )
            )
        }
        
        sections.append(
            .init(
                rows: [
                    Row(text: Strings.RewardsInternals.promotionsTitle, selection: { [unowned self] in
                        let controller = RewardsInternalsPromotionListController(ledger: self.ledger)
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, accessory: .disclosureIndicator),
                    Row(text: Strings.RewardsInternals.contributionsTitle, selection: { [unowned self] in
                        let controller = RewardsInternalsContributionListController(ledger: self.ledger)
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, accessory: .disclosureIndicator),
                    Row(text: "Auto-Contribute", selection: { [unowned self] in
                        let controller = RewardsInternalsAutoContributeController(ledger: self.ledger)
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, accessory: .disclosureIndicator)
                ]
            )
        )
        
        dataSource.sections = sections
    }
    
    @objc private func tappedShare() {
        let controller = RewardsInternalsShareController(ledger: self.ledger, initiallySelectedSharables: RewardsInternalsSharable.qa, sharables: RewardsInternalsSharable.qa)
        let container = UINavigationController(rootViewController: controller)
        present(container, animated: true)
    }
}
