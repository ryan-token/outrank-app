//
//  LastPlace.swift
//  Outrank
//

import Foundation

/// Where the user last was in the app, so the next launch opens there.
///
/// Saved to user defaults the moment it changes. Scene storage is only saved when the
/// system snapshots the scene on its way to the background, so an app that ends any other
/// way reopens at an older place.
enum LastPlace {
    static var tab: AppTab {
        get { value(forKey: "ActiveTab") ?? .rankings }
        set { set(newValue, forKey: "ActiveTab") }
    }

    /// The Settings page that is open, if any.
    static var settingsDetail: SettingsDetail? {
        get { value(forKey: "SettingsDetail") }
        set { set(newValue, forKey: "SettingsDetail") }
    }

    /// The stat that is open on the Rankings tab, if any.
    static var selectedStat: String? {
        get { UserDefaults.standard.string(forKey: "SelectedStat") }
        set { UserDefaults.standard.set(newValue, forKey: "SelectedStat") }
    }

    private static func value<Value: RawRepresentable<String>>(forKey key: String) -> Value? {
        UserDefaults.standard.string(forKey: key).flatMap { Value(rawValue: $0) }
    }

    private static func set<Value: RawRepresentable<String>>(_ value: Value?, forKey key: String) {
        UserDefaults.standard.set(value?.rawValue, forKey: key)
    }
}
