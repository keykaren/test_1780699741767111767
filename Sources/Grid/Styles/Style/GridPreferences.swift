import Foundation
import CoreGraphics

public struct GridPreferences: Equatable {
    public struct Item: Equatable {
        public let id: AnyHashable
        public let bounds: CGRect
        
        public init(id: AnyHashable, bounds: CGRect) {
            self.id = id
            self.bounds = bounds
        }
    }

    private var storedItems: [Item]
    private var itemIndex: [AnyHashable: Int]

    public var items: [Item] {
        get {
            storedItems
        }
        set {
            storedItems = newValue
            itemIndex = GridPreferences.makeIndex(for: newValue)
        }
    }

    public var size: CGSize

    public init(size: CGSize = .zero, items: [Item]) {
        self.size = size
        self.storedItems = items
        self.itemIndex = GridPreferences.makeIndex(for: items)
    }

    public static func == (lhs: GridPreferences, rhs: GridPreferences) -> Bool {
        lhs.size == rhs.size && lhs.storedItems == rhs.storedItems
    }
    
    subscript(id: AnyHashable) -> Item? {
        get {
            guard let index = itemIndex[id] else { return nil }
            return storedItems[index]
        }
    }
    
    mutating func merge(with preferences: GridPreferences) {
        let firstNewIndex = self.storedItems.count
        self.storedItems.append(contentsOf: preferences.storedItems)

        for (offset, item) in preferences.storedItems.enumerated() {
            if self.itemIndex[item.id] == nil {
                self.itemIndex[item.id] = firstNewIndex + offset
            }
        }

        self.size = CGSize(
            width: (self.storedItems.map { $0.bounds.origin.x + $0.bounds.size.width }.max() ?? 0.0).rounded(),
            height: (self.storedItems.map { $0.bounds.origin.y + $0.bounds.size.height }.max() ?? 0.0).rounded()
        )
    }

    private static func makeIndex(for items: [Item]) -> [AnyHashable: Int] {
        var index: [AnyHashable: Int] = [:]
        index.reserveCapacity(items.count)

        for (offset, item) in items.enumerated() where index[item.id] == nil {
            index[item.id] = offset
        }

        return index
    }
}
