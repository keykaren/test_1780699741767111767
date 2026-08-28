import Grid
import XCTest

final class GridItemBoundsPublicAPITests: XCTestCase {
    func testIdentityAwareBoundsAPIIsPublic() {
        let uuid = UUID()
        let preferences = GridItemBoundsPreferences(items: [
            GridItemBoundsPreferences.Item(id: AnyHashable(uuid), bounds: CGRect(x: 1, y: 2, width: 3, height: 4)),
            GridItemBoundsPreferences.Item(id: AnyHashable("card"), bounds: CGRect(x: 5, y: 6, width: 7, height: 8)),
            GridItemBoundsPreferences.Item(id: AnyHashable(42), bounds: CGRect(x: 9, y: 10, width: 11, height: 12))
        ])

        let entries: [GridItemBoundsPreferences.Item] = preferences.items
        let uuidBounds: CGRect? = preferences[id: uuid]
        let stringBounds: CGRect? = preferences[id: "card"]
        let intBounds: CGRect? = preferences[id: 42]
        let value: GridItemBoundsByIDPreferencesKey.Value = preferences

        XCTAssertEqual(entries.map { $0.id }, [AnyHashable(uuid), AnyHashable("card"), AnyHashable(42)])
        XCTAssertEqual(uuidBounds, entries[0].bounds)
        XCTAssertEqual(stringBounds, entries[1].bounds)
        XCTAssertEqual(intBounds, entries[2].bounds)
        XCTAssertEqual(value, preferences)
    }
}
