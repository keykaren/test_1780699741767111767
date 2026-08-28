import SwiftUI

/// Item bounds emitted by a `Grid`, paired with the identity used by the grid.
public struct GridItemBoundsPreferences: Equatable {
    /// The identity and bounds of one preference contribution.
    public struct Item: Identifiable, Equatable {
        public let id: AnyHashable
        public let bounds: CGRect

        public init(id: AnyHashable, bounds: CGRect) {
            self.id = id
            self.bounds = bounds
        }
    }

    public private(set) var items: [Item]

    public init(items: [Item] = []) {
        self.items = items
    }

    /// Returns bounds only when exactly one contribution has the supplied ID.
    public subscript<ID: Hashable>(id id: ID) -> CGRect? {
        let matches = allBounds(for: id)
        return matches.count == 1 ? matches[0] : nil
    }

    /// Returns every bound with the supplied ID in contribution order.
    public func allBounds<ID: Hashable>(for id: ID) -> [CGRect] {
        let id = AnyHashable(id)
        return items.compactMap { item in
            item.id == id ? item.bounds : nil
        }
    }
}

/// A preference key for reading grid item bounds by grid item identity.
public struct GridItemBoundsByIDPreferencesKey: PreferenceKey {
    public typealias Value = GridItemBoundsPreferences

    public static var defaultValue: GridItemBoundsPreferences = .init()

    public static func reduce(value: inout GridItemBoundsPreferences, nextValue: () -> GridItemBoundsPreferences) {
        value = GridItemBoundsPreferences(items: value.items + nextValue().items)
    }
}
