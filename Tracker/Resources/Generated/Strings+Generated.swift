// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// день
  internal static let day = L10n.tr("Localizable", "day", fallback: "день")
  /// Фильтры
  internal static let filters = L10n.tr("Localizable", "filters", fallback: "Фильтры")
  /// Plural format key: "%#@days@"
  internal static func numberOfDays(_ p1: Int) -> String {
    return L10n.tr("Localizable", "numberOfDays", p1, fallback: "Plural format key: \"%#@days@\"")
  }
  internal enum Main {
    /// Localizable.strings
    ///   Tracker
    /// 
    internal static let title = L10n.tr("Localizable", "main.title", fallback: "Трекеры")
  }
  internal enum Statistics {
    /// Статистика
    internal static let title = L10n.tr("Localizable", "statistics.title", fallback: "Статистика")
  }
  internal enum Tabbar {
    /// Статистика
    internal static let statistics = L10n.tr("Localizable", "tabbar.statistics", fallback: "Статистика")
    /// Трекеры
    internal static let trackers = L10n.tr("Localizable", "tabbar.trackers", fallback: "Трекеры")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
