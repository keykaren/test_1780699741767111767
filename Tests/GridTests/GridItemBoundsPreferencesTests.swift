import Grid
import XCTest

final class GridItemBoundsPreferencesTests: XCTestCase {
    private struct CollidingID: Hashable {
        let value: String

        static func == (lhs: CollidingID, rhs: CollidingID) -> Bool {
            lhs.value == rhs.value
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(0)
        }
    }

    func testEmptyDefaultAndMissingLookups() {
        let preferences = GridItemBoundsByIDPreferencesKey.defaultValue

        XCTAssertEqual(preferences.items, [])
        XCTAssertNil(preferences[id: UUID()])
        XCTAssertNil(preferences[id: "missing"])
        XCTAssertNil(preferences[id: 1])
        XCTAssertEqual(preferences.allBounds(for: "missing"), [])
    }

    func testZeroBoundsArePresent() {
        let preferences = makePreferences(("zero", .zero))

        let bounds = preferences[id: "zero"]
        XCTAssertNotNil(bounds)
        XCTAssertEqual(bounds, CGRect.zero)
    }

    func testHeterogeneousAndCollidingIDsRemainDistinct() {
        let uuid = UUID()
        let firstCollision = CollidingID(value: "first")
        let secondCollision = CollidingID(value: "second")
        let rectangles = (0..<5).map {
            CGRect(x: CGFloat($0 * 10), y: 0, width: 10, height: 10)
        }
        let preferences = GridItemBoundsPreferences(items: [
            .init(id: AnyHashable(uuid), bounds: rectangles[0]),
            .init(id: AnyHashable("string"), bounds: rectangles[1]),
            .init(id: AnyHashable(7), bounds: rectangles[2]),
            .init(id: AnyHashable(firstCollision), bounds: rectangles[3]),
            .init(id: AnyHashable(secondCollision), bounds: rectangles[4])
        ])

        XCTAssertEqual(preferences[id: uuid], rectangles[0])
        XCTAssertEqual(preferences[id: "string"], rectangles[1])
        XCTAssertEqual(preferences[id: 7], rectangles[2])
        XCTAssertEqual(preferences[id: firstCollision], rectangles[3])
        XCTAssertEqual(preferences[id: secondCollision], rectangles[4])
        XCTAssertEqual(firstCollision.hashValue, secondCollision.hashValue)
        XCTAssertNotEqual(AnyHashable(firstCollision), AnyHashable(secondCollision))
    }

    func testReorderingUpdatesOrderAndBoundsByIdentity() {
        let original = makePreferences(
            ("a", CGRect(x: 0, y: 0, width: 10, height: 10)),
            ("b", CGRect(x: 10, y: 0, width: 10, height: 10))
        )
        let reordered = makePreferences(
            ("b", CGRect(x: 0, y: 0, width: 20, height: 10)),
            ("a", CGRect(x: 20, y: 0, width: 20, height: 10))
        )

        XCTAssertEqual(original.items.map { $0.id }, [AnyHashable("a"), AnyHashable("b")])
        XCTAssertEqual(reordered.items.map { $0.id }, [AnyHashable("b"), AnyHashable("a")])
        XCTAssertEqual(reordered[id: "a"], CGRect(x: 20, y: 0, width: 20, height: 10))
        XCTAssertEqual(reordered[id: "b"], CGRect(x: 0, y: 0, width: 20, height: 10))
    }

    func testRemovedIdentityHasNoStaleBounds() {
        let beforeRemoval = makePreferences(
            ("kept", CGRect(x: 0, y: 0, width: 10, height: 10)),
            ("removed", CGRect(x: 10, y: 0, width: 10, height: 10))
        )
        let afterRemoval = makePreferences(
            ("kept", CGRect(x: 5, y: 5, width: 20, height: 20))
        )

        XCTAssertNotNil(beforeRemoval[id: "removed"])
        XCTAssertNil(afterRemoval[id: "removed"])
        XCTAssertEqual(afterRemoval[id: "kept"], CGRect(x: 5, y: 5, width: 20, height: 20))
    }

    func testReductionRetainsDuplicatesAndContributionOrder() {
        let duplicate = "duplicate"
        let first = CGRect(x: 0, y: 0, width: 10, height: 10)
        let unique = CGRect(x: 10, y: 0, width: 10, height: 10)
        let second = CGRect(x: 20, y: 0, width: 10, height: 10)
        var preferences = GridItemBoundsByIDPreferencesKey.defaultValue

        GridItemBoundsByIDPreferencesKey.reduce(value: &preferences) {
            self.makePreferences((duplicate, first), ("unique", unique))
        }
        GridItemBoundsByIDPreferencesKey.reduce(value: &preferences) {
            self.makePreferences((duplicate, second))
        }

        XCTAssertEqual(preferences.items.map { $0.id }, [
            AnyHashable(duplicate), AnyHashable("unique"), AnyHashable(duplicate)
        ])
        XCTAssertEqual(preferences.items.map { $0.bounds }, [first, unique, second])
        XCTAssertEqual(preferences.allBounds(for: duplicate), [first, second])
        XCTAssertNil(preferences[id: duplicate])
        XCTAssertEqual(preferences[id: "unique"], unique)
    }

    func testLegacyBoundsPreferenceRemainsAnAppendingArray() {
        let first = CGRect(x: 1, y: 2, width: 3, height: 4)
        let second = CGRect(x: 5, y: 6, width: 7, height: 8)
        var preferences: GridItemBoundsPreferencesKey.Value = GridItemBoundsPreferencesKey.defaultValue

        XCTAssertEqual(preferences, [])
        GridItemBoundsPreferencesKey.reduce(value: &preferences) { [first] }
        GridItemBoundsPreferencesKey.reduce(value: &preferences) { [second] }

        let sourceCompatibleArray: [CGRect] = preferences
        XCTAssertEqual(sourceCompatibleArray, [first, second])
    }

    private func makePreferences<ID: Hashable>(_ values: (ID, CGRect)...) -> GridItemBoundsPreferences {
        GridItemBoundsPreferences(items: values.map {
            GridItemBoundsPreferences.Item(id: AnyHashable($0.0), bounds: $0.1)
        })
    }
}
