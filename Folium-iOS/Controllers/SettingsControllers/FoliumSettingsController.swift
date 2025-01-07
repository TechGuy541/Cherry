//
//  FoliumSettingsController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 29/10/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import UIKit
class BoolSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var value: Bool
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, value: Bool, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.value = value
        self.delegate = delegate
    }
}

class InputNumberSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var min, max, value: Double
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, min: Double, max: Double, value: Double, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.min = min
        self.max = max
        self.value = value
        self.delegate = delegate
    }
}

class InputStringSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var placeholder, value: String?
    let action: () -> Void
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, placeholder: String? = nil, value: String? = nil,
         action: @escaping () -> Void, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.placeholder = placeholder
        self.value = value
        self.action = action
        self.delegate = delegate
    }
}

class StepperSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var min, max, value: Double
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, min: Double, max: Double, value: Double, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.min = min
        self.max = max
        self.value = value
        self.delegate = delegate
    }
}

class SelectionSetting : AnyHashableSendable, @unchecked Sendable {
    var key, title: String
    var details: String?
    var values: [String : Any]
    var selectedValue: Any? = nil
    
    var delegate: SettingDelegate? = nil
    
    init(key: String, title: String, details: String? = nil, values: [String : Any], selectedValue: Any? = nil, delegate: SettingDelegate? = nil) {
        self.key = key
        self.title = title
        self.details = details
        self.values = values
        self.selectedValue = selectedValue
        self.delegate = delegate
    }
}

protocol SettingDelegate {
    func didChangeSetting(at indexPath: IndexPath)
}

class FoliumSettingsController : UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<String, AnyHashableSendable>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<String, AnyHashableSendable>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButton(.init(systemItem: .close, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        prefersLargeTitles(true)
        title = "Settings"
        
        let boolCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BoolSetting> { cell, indexPath, itemIdentifier in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = itemIdentifier.title
            cell.contentConfiguration = contentConfiguration
            
            let toggle = UISwitch(frame: .zero, primaryAction: .init(handler: { action in
                guard let toggle = action.sender as? UISwitch else {
                    return
                }
                
                UserDefaults.standard.set(toggle.isOn, forKey: itemIdentifier.key)
                if let delegate = itemIdentifier.delegate {
                    delegate.didChangeSetting(at: indexPath)
                }
            }))
            toggle.isOn = itemIdentifier.value
            
            cell.accessories = if let details = itemIdentifier.details {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing())),
                    .detail(options: .init(tintColor: .systemBlue), actionHandler: {
                        let alertController = UIAlertController(title: "\(itemIdentifier.title) Details", message: details, preferredStyle: .alert)
                        alertController.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alertController, animated: true)
                    })
                ]
            } else {
                [
                    .customView(configuration: .init(customView: toggle, placement: .trailing()))
                ]
            }
        }
        
        let headerCellRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var contentConfiguration = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            contentConfiguration.text = self.snapshot.sectionIdentifiers[indexPath.section]
            supplementaryView.contentConfiguration = contentConfiguration
        }
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let boolSetting as BoolSetting:
                collectionView.dequeueConfiguredReusableCell(using: boolCellRegistration, for: indexPath, item: boolSetting)
            default:
                nil
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
        }
        
        snapshot = .init()
        snapshot.appendSections([
            "Library"
        ])
        
        snapshot.appendItems([
            BoolSetting(key: "folium.showBetaConsoles",
                        title: "Show Beta Consoles",
                        details: "Determines whether or not to show consoles that are in a beta state",
                        value: UserDefaults.standard.bool(forKey: "folium.showBetaConsoles"),
                        delegate: self),
            BoolSetting(key: "folium.showConsoleNames",
                        title: "Show Console Names",
                        details: "Determines whether or not to show the name of the console under the core name",
                        value: UserDefaults.standard.bool(forKey: "folium.showConsoleNames"),
                        delegate: self),
            BoolSetting(key: "folium.showGameTitles",
                        title: "Show Game Titles",
                        details: "Determines whether or not to show game titles. Games without artwork always have titles shown",
                        value: UserDefaults.standard.bool(forKey: "folium.showGameTitles"),
                        delegate: self)
        ], toSection: "Library")
        
        Task {
            await dataSource.apply(snapshot)
        }
    }
}

extension FoliumSettingsController : SettingDelegate {
    
    func didChangeSetting(at indexPath: IndexPath) {
        guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
            return
        }
        
        var snapshot = dataSource.snapshot()
        let item = snapshot.itemIdentifiers(inSection: sectionIdentifier)[indexPath.item]
        
        switch item {
        case let boolSetting as BoolSetting:
            boolSetting.value = UserDefaults.standard.bool(forKey: boolSetting.key)
        default:
            break
        }
        
        snapshot.reloadItems([item])
        Task {
            await dataSource.apply(snapshot)
        }
    }
}
