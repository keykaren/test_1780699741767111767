import SwiftUI
@testable import Grid
import XCTest

final class GridInitializerIdentityTests: XCTestCase {
    private struct IdentifiableValue: Identifiable {
        let id: String
    }

    private struct KeyPathValue {
        let key: UUID
    }

    func testIdentifiableInitializerUsesElementID() {
        let values = [IdentifiableValue(id: "first"), IdentifiableValue(id: "second")]
        let grid = Grid(values) { _ in EmptyView() }

        XCTAssertEqual(grid.items.map { $0.id }, values.map { AnyHashable($0.id) })
    }

    func testKeyPathInitializerUsesSelectedValue() {
        let values = [KeyPathValue(key: UUID()), KeyPathValue(key: UUID())]
        let grid = Grid(values, id: \.key) { _ in EmptyView() }

        XCTAssertEqual(grid.items.map { $0.id }, values.map { AnyHashable($0.key) })
    }

    func testRangeInitializerUsesInteger() {
        let grid = Grid(3..<6) { _ in EmptyView() }

        XCTAssertEqual(grid.items.map { $0.id }, [AnyHashable(3), AnyHashable(4), AnyHashable(5)])
    }

    func testStaticTupleInitializerUsesPositions() {
        let grid = Grid.Grid {
            EmptyView()
            Color.clear
            Text("third")
        }

        XCTAssertEqual(grid.items.map { $0.id }, [AnyHashable(0), AnyHashable(1), AnyHashable(2)])
    }
}
