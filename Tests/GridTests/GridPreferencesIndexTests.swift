import enum SwiftUI.Axis
@testable import Grid
import XCTest

final class GridPreferencesIndexTests: XCTestCase {
    private let itemCount = 256

    func testSnapshotConstructionAndRepeatedLookupUseLinearIdentityWork() {
        let counter = IdentityOperationCounter()
        let ids = (0..<itemCount).map { CountingID(value: $0, counter: counter) }
        counter.reset()

        let preferences = GridPreferences(items: ids.map {
            GridPreferences.Item(id: AnyHashable($0), bounds: bounds($0.value))
        })
        assertLinearIdentityWork(counter, phase: "snapshot construction")

        counter.reset()
        for _ in 0..<5 {
            for id in ids {
                XCTAssertEqual(preferences[AnyHashable(id)]?.bounds, bounds(id.value))
            }
        }
        assertLinearIdentityWork(counter, phase: "five successful lookup passes")

        counter.reset()
        for value in itemCount..<(itemCount * 2) {
            let missing = CountingID(value: value, counter: counter)
            XCTAssertNil(preferences[AnyHashable(missing)])
        }
        assertLinearIdentityWork(counter, phase: "one missing lookup pass")
    }

    func testSequentialOneItemMergesAndLookupUseLinearIdentityWork() {
        let counter = IdentityOperationCounter()
        let ids = (0..<itemCount).map { CountingID(value: $0, counter: counter) }
        counter.reset()

        var preferences = GridPreferences(items: [])
        for id in ids {
            preferences.merge(with: GridPreferences(items: [
                GridPreferences.Item(id: AnyHashable(id), bounds: bounds(id.value))
            ]))
        }
        for id in ids {
            XCTAssertEqual(preferences[AnyHashable(id)]?.bounds, bounds(id.value))
        }

        assertLinearIdentityWork(counter, phase: "sequential merges and lookup pass")
        XCTAssertEqual(preferences.items.count, itemCount)
    }

    func testRepeatedLookupReusesTheExistingIndex() {
        let counter = IdentityOperationCounter()
        let ids = (0..<64).map { CountingID(value: $0, counter: counter) }
        let preferences = GridPreferences(items: ids.map {
            GridPreferences.Item(id: AnyHashable($0), bounds: bounds($0.value))
        })
        let sought = ids[37]
        counter.reset()

        for _ in 0..<20 {
            XCTAssertEqual(preferences[AnyHashable(sought)]?.bounds, bounds(sought.value))
        }

        XCTAssertEqual(Set(counter.hashedValues), Set([sought.value]))
        XCTAssertLessThanOrEqual(counter.hashingCalls, 20 * 2)
        XCTAssertLessThanOrEqual(counter.equalityCalls, 20 * 2)
    }

    func testIncrementalMergesDoNotRepeatedlyRescanEarlierIdentities() {
        let count = 64
        let counter = IdentityOperationCounter()
        var preferences = GridPreferences(items: [])
        counter.reset()

        for value in 0..<count {
            let id = CountingID(value: value, counter: counter)
            preferences.merge(with: GridPreferences(items: [
                GridPreferences.Item(id: AnyHashable(id), bounds: bounds(value))
            ]))
        }

        let hashesByIdentity = Dictionary(grouping: counter.hashedValues, by: { $0 })
        XCTAssertEqual(Set(hashesByIdentity.keys), Set(0..<count))
        for value in 0..<count {
            XCTAssertLessThanOrEqual(
                hashesByIdentity[value, default: []].count,
                16,
                "Identity \(value) was repeatedly rescanned by later merges"
            )
        }
        XCTAssertLessThanOrEqual(counter.hashingCalls, 16 * count)
    }

    func testEmptyMissingDuplicateHeterogeneousAndCollidingIDs() {
        let empty = GridPreferences(items: [])
        XCTAssertNil(empty[AnyHashable("missing")])

        let duplicate = AnyHashable("duplicate")
        let collisionA = CollidingID(value: "a")
        let collisionB = CollidingID(value: "b")
        let uuid = UUID()
        let preferences = GridPreferences(items: [
            item(duplicate, marker: 1),
            item(AnyHashable(collisionA), marker: 2),
            item(AnyHashable(collisionB), marker: 3),
            item(AnyHashable(uuid), marker: 4),
            item(AnyHashable(7), marker: 5),
            item(AnyHashable("7"), marker: 6),
            item(duplicate, marker: 7)
        ])

        XCTAssertEqual(preferences[duplicate]?.bounds, bounds(1))
        XCTAssertEqual(preferences[AnyHashable(collisionA)]?.bounds, bounds(2))
        XCTAssertEqual(preferences[AnyHashable(collisionB)]?.bounds, bounds(3))
        XCTAssertEqual(collisionA.hashValue, collisionB.hashValue)
        XCTAssertNotEqual(AnyHashable(collisionA), AnyHashable(collisionB))
        XCTAssertEqual(preferences[AnyHashable(uuid)]?.bounds, bounds(4))
        XCTAssertEqual(preferences[AnyHashable(7)]?.bounds, bounds(5))
        XCTAssertEqual(preferences[AnyHashable("7")]?.bounds, bounds(6))
        XCTAssertNil(preferences[AnyHashable("absent")])
        XCTAssertEqual(preferences.items.count, 7)
        XCTAssertEqual(preferences.items.filter { $0.id == duplicate }.count, 2)

        XCTAssertEqual(AnyHashable(Int8(9)), AnyHashable(Int(9)))
        let numeric = GridPreferences(items: [item(AnyHashable(Int8(9)), marker: 9)])
        XCTAssertEqual(numeric[AnyHashable(Int(9))]?.bounds, bounds(9))
    }

    func testDirectItemMutationsRebuildCoherentFirstMatchIndexes() {
        var preferences = GridPreferences(items: [item("a", marker: 1), item("b", marker: 2)])
        XCTAssertEqual(preferences[AnyHashable("a")]?.bounds, bounds(1))

        preferences.items = [item("c", marker: 3), item("d", marker: 4)]
        XCTAssertNil(preferences[AnyHashable("a")])
        XCTAssertEqual(preferences[AnyHashable("c")]?.bounds, bounds(3))

        preferences.items.append(item("e", marker: 5))
        XCTAssertEqual(preferences[AnyHashable("e")]?.bounds, bounds(5))

        _ = preferences.items.remove(at: 0)
        XCTAssertNil(preferences[AnyHashable("c")])
        XCTAssertEqual(preferences[AnyHashable("d")]?.bounds, bounds(4))

        preferences.items[0] = item("replacement", marker: 6)
        XCTAssertNil(preferences[AnyHashable("d")])
        XCTAssertEqual(preferences[AnyHashable("replacement")]?.bounds, bounds(6))

        preferences.items.append(item("replacement", marker: 7))
        preferences.items.reverse()
        XCTAssertEqual(preferences.items.map { $0.id }, [
            AnyHashable("replacement"), AnyHashable("e"), AnyHashable("replacement")
        ])
        XCTAssertEqual(preferences[AnyHashable("replacement")]?.bounds, bounds(7))

        preferences.size = CGSize(width: 123, height: 456)
        XCTAssertEqual(preferences.size, CGSize(width: 123, height: 456))
        XCTAssertEqual(preferences[AnyHashable("e")]?.bounds, bounds(5))
    }

    func testMergeAndPreferenceReducerKeepFirstMatchesAndNewIDsCoherent() {
        var merged = GridPreferences(items: [item("first", marker: 1)])
        XCTAssertEqual(merged[AnyHashable("first")]?.bounds, bounds(1))

        merged.merge(with: GridPreferences(items: [
            item("first", marker: 2),
            item("second", marker: 3)
        ]))
        XCTAssertEqual(merged.items.map { $0.id }, [
            AnyHashable("first"), AnyHashable("first"), AnyHashable("second")
        ])
        XCTAssertEqual(merged[AnyHashable("first")]?.bounds, bounds(1))
        XCTAssertEqual(merged[AnyHashable("second")]?.bounds, bounds(3))

        GridPreferencesKey.reduce(value: &merged) {
            GridPreferences(items: [item("third", marker: 4)])
        }
        XCTAssertEqual(merged[AnyHashable("first")]?.bounds, bounds(1))
        XCTAssertEqual(merged[AnyHashable("third")]?.bounds, bounds(4))
        XCTAssertEqual(merged.items.count, 4)
    }

    func testCopiedPreferencesHaveIndependentItemsAndIndexes() {
        var original = GridPreferences(items: [item("a", marker: 1), item("b", marker: 2)])
        XCTAssertEqual(original[AnyHashable("a")]?.bounds, bounds(1))
        var copy = original

        copy.items[0] = item("copy-a", marker: 3)
        copy.merge(with: GridPreferences(items: [item("copy-c", marker: 4)]))
        original.items.append(item("original-c", marker: 5))

        XCTAssertEqual(original[AnyHashable("a")]?.bounds, bounds(1))
        XCTAssertNil(original[AnyHashable("copy-a")])
        XCTAssertNil(original[AnyHashable("copy-c")])
        XCTAssertEqual(original[AnyHashable("original-c")]?.bounds, bounds(5))
        XCTAssertNil(copy[AnyHashable("a")])
        XCTAssertEqual(copy[AnyHashable("copy-a")]?.bounds, bounds(3))
        XCTAssertEqual(copy[AnyHashable("copy-c")]?.bounds, bounds(4))
        XCTAssertNil(copy[AnyHashable("original-c")])
    }

    func testLookupStateDoesNotParticipateInEquality() {
        let items = [item("a", marker: 1), item("b", marker: 2)]
        let warmed = GridPreferences(size: CGSize(width: 10, height: 20), items: items)
        let unwarmed = GridPreferences(size: CGSize(width: 10, height: 20), items: items)

        for _ in 0..<20 {
            XCTAssertNotNil(warmed[AnyHashable("a")])
            XCTAssertNil(warmed[AnyHashable("missing")])
        }

        XCTAssertEqual(warmed, unwarmed)
    }

    func testCustomStyleCanMutateItemsWithoutLeavingStaleLookups() {
        var preferences = GridPreferences(items: [
            item("a", marker: 1), item("b", marker: 2), item("c", marker: 3)
        ])
        XCTAssertNotNil(preferences[AnyHashable("a")])

        ItemMutatingStyle().transform(preferences: &preferences, in: CGSize(width: 100, height: 100))

        XCTAssertEqual(preferences.items.map { $0.id }, [
            AnyHashable("appended"), AnyHashable("c"), AnyHashable("replacement")
        ])
        XCTAssertNil(preferences[AnyHashable("a")])
        XCTAssertNil(preferences[AnyHashable("b")])
        XCTAssertEqual(preferences[AnyHashable("c")]?.bounds, bounds(3))
        XCTAssertEqual(preferences[AnyHashable("replacement")]?.bounds, bounds(8))
        XCTAssertEqual(preferences[AnyHashable("appended")]?.bounds, bounds(9))
    }

    private func assertLinearIdentityWork(
        _ counter: IdentityOperationCounter,
        phase: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let limit = 16 * itemCount
        XCTAssertLessThanOrEqual(counter.hashingCalls, limit, "Too much hashing during \(phase)", file: file, line: line)
        XCTAssertLessThanOrEqual(counter.equalityCalls, limit, "Too many comparisons during \(phase)", file: file, line: line)
        XCTAssertLessThanOrEqual(counter.hashingCalls + counter.equalityCalls, limit, "Too much combined identity work during \(phase)", file: file, line: line)
    }

    private func bounds(_ marker: Int) -> CGRect {
        CGRect(x: CGFloat(marker), y: 0, width: 1, height: 1)
    }

    private func item<ID: Hashable>(_ id: ID, marker: Int) -> GridPreferences.Item {
        GridPreferences.Item(id: AnyHashable(id), bounds: bounds(marker))
    }
}

private final class IdentityOperationCounter {
    private(set) var equalityCalls = 0
    private(set) var hashingCalls = 0
    private(set) var hashedValues: [Int] = []

    func recordEquality() {
        equalityCalls += 1
    }

    func recordHash(of value: Int) {
        hashingCalls += 1
        hashedValues.append(value)
    }

    func reset() {
        equalityCalls = 0
        hashingCalls = 0
        hashedValues = []
    }
}

private struct CountingID: Hashable {
    let value: Int
    let counter: IdentityOperationCounter

    static func == (lhs: CountingID, rhs: CountingID) -> Bool {
        lhs.counter.recordEquality()
        return lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        counter.recordHash(of: value)
        hasher.combine(value)
    }
}

private struct CollidingID: Hashable {
    let value: String

    static func == (lhs: CollidingID, rhs: CollidingID) -> Bool {
        lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
}

private struct ItemMutatingStyle: GridStyle {
    var axis: Axis { .vertical }
    var autoWidth: Bool { true }
    var autoHeight: Bool { true }

    func transform(preferences: inout GridPreferences, in size: CGSize) {
        _ = preferences.items.removeFirst()
        preferences.items[0] = GridPreferences.Item(
            id: AnyHashable("replacement"),
            bounds: CGRect(x: 8, y: 0, width: 1, height: 1)
        )
        preferences.items.append(GridPreferences.Item(
            id: AnyHashable("appended"),
            bounds: CGRect(x: 9, y: 0, width: 1, height: 1)
        ))
        preferences.items.reverse()
    }
}
