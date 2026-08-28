import struct SwiftUI.EmptyView
import struct SwiftUI.TupleView
import protocol SwiftUI.View
import struct SwiftUI.ViewBuilder
@testable import Grid
import XCTest

final class StaticGridInitializerTests: XCTestCase {
    func testOrdinaryViewBuilderContentIsEvaluatedOnceForEveryArity() {
        let recorder = StaticGridConstructionRecorder()

        var before = recorder.snapshot
        let grid2 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
        })
        assertInitialization(grid2, arity: 2, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid3 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
        })
        assertInitialization(grid3, arity: 3, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid4 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
        })
        assertInitialization(grid4, arity: 4, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid5 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
        })
        assertInitialization(grid5, arity: 5, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid6 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
            recorder.produce(5)
        })
        assertInitialization(grid6, arity: 6, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid7 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
            recorder.produce(5)
            recorder.produce(6)
        })
        assertInitialization(grid7, arity: 7, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid8 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
            recorder.produce(5)
            recorder.produce(6)
            recorder.produce(7)
        })
        assertInitialization(grid8, arity: 8, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid9 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
            recorder.produce(5)
            recorder.produce(6)
            recorder.produce(7)
            recorder.produce(8)
        })
        assertInitialization(grid9, arity: 9, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid10 = Grid(content: recorder.instrument {
            recorder.produce(0)
            recorder.produce(1)
            recorder.produce(2)
            recorder.produce(3)
            recorder.produce(4)
            recorder.produce(5)
            recorder.produce(6)
            recorder.produce(7)
            recorder.produce(8)
            recorder.produce(9)
        })
        assertInitialization(grid10, arity: 10, recorder: recorder, before: before)

        XCTAssertEqual(recorder.builderInvocations, 9)
        XCTAssertEqual(recorder.constructionOrder.count, 54)
    }

    func testInstrumentedTupleContentIsEvaluatedOnceForEveryArity() {
        let recorder = StaticGridConstructionRecorder()

        var before = recorder.snapshot
        let grid2 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1)))
        })
        assertInitialization(grid2, arity: 2, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid3 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2)))
        })
        assertInitialization(grid3, arity: 3, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid4 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3)))
        })
        assertInitialization(grid4, arity: 4, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid5 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4)))
        })
        assertInitialization(grid5, arity: 5, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid6 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4), recorder.produce(5)))
        })
        assertInitialization(grid6, arity: 6, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid7 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4), recorder.produce(5), recorder.produce(6)))
        })
        assertInitialization(grid7, arity: 7, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid8 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4), recorder.produce(5), recorder.produce(6), recorder.produce(7)))
        })
        assertInitialization(grid8, arity: 8, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid9 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4), recorder.produce(5), recorder.produce(6), recorder.produce(7), recorder.produce(8)))
        })
        assertInitialization(grid9, arity: 9, recorder: recorder, before: before)

        before = recorder.snapshot
        let grid10 = Grid(content: recorder.instrument {
            TupleView((recorder.produce(0), recorder.produce(1), recorder.produce(2), recorder.produce(3), recorder.produce(4), recorder.produce(5), recorder.produce(6), recorder.produce(7), recorder.produce(8), recorder.produce(9)))
        })
        assertInitialization(grid10, arity: 10, recorder: recorder, before: before)

        XCTAssertEqual(recorder.builderInvocations, 9)
        XCTAssertEqual(recorder.constructionOrder.count, 54)
    }

    func testCollectionExplicitIDAndRangeInitializersRemainEagerAndOrdered() {
        let identifiableRecorder = StaticGridConstructionRecorder()
        let identifiableValues = [
            StaticIdentifiableValue(id: "c", position: 2),
            StaticIdentifiableValue(id: "a", position: 0),
            StaticIdentifiableValue(id: "b", position: 1)
        ]
        let identifiableGrid = Grid(identifiableValues) {
            identifiableRecorder.produce($0.position)
        }

        XCTAssertEqual(identifiableRecorder.constructionOrder, [2, 0, 1])
        XCTAssertEqual(identifiableGrid.items.map { $0.id }, [AnyHashable("c"), AnyHashable("a"), AnyHashable("b")])

        let explicitRecorder = StaticGridConstructionRecorder()
        let explicitValues = [
            StaticExplicitIDValue(id: 30, position: 3),
            StaticExplicitIDValue(id: 10, position: 1),
            StaticExplicitIDValue(id: 20, position: 2)
        ]
        let explicitGrid = Grid(explicitValues, id: \.id) {
            explicitRecorder.produce($0.position)
        }

        XCTAssertEqual(explicitRecorder.constructionOrder, [3, 1, 2])
        XCTAssertEqual(explicitGrid.items.map { $0.id }, [AnyHashable(30), AnyHashable(10), AnyHashable(20)])

        let rangeRecorder = StaticGridConstructionRecorder()
        let rangeGrid = Grid(4..<8) {
            rangeRecorder.produce($0)
        }

        XCTAssertEqual(rangeRecorder.constructionOrder, [4, 5, 6, 7])
        XCTAssertEqual(rangeGrid.items.map { $0.id }, [AnyHashable(4), AnyHashable(5), AnyHashable(6), AnyHashable(7)])
    }

    private func assertInitialization<Content: View>(
        _ grid: Grid<Content>,
        arity: Int,
        recorder: StaticGridConstructionRecorder,
        before: StaticGridConstructionRecorder.Snapshot,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let newConstructions = Array(recorder.constructionOrder.dropFirst(before.constructionCount))

        XCTAssertEqual(recorder.builderInvocations - before.builderInvocations, 1, file: file, line: line)
        XCTAssertEqual(newConstructions, Array(0..<arity), file: file, line: line)
        XCTAssertEqual(newConstructions.count, arity, file: file, line: line)
        for position in 0..<arity {
            XCTAssertEqual(newConstructions.filter { $0 == position }.count, 1, file: file, line: line)
        }
        XCTAssertEqual(grid.items.count, arity, file: file, line: line)
        XCTAssertEqual(grid.items.map { $0.id }, (0..<arity).map { AnyHashable($0) }, file: file, line: line)
    }
}

private final class StaticGridConstructionRecorder {
    struct Snapshot {
        let builderInvocations: Int
        let constructionCount: Int
    }

    private(set) var builderInvocations = 0
    private(set) var constructionOrder: [Int] = []

    var snapshot: Snapshot {
        Snapshot(
            builderInvocations: builderInvocations,
            constructionCount: constructionOrder.count
        )
    }

    func instrument<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> () -> Content {
        return {
            self.builderInvocations += 1
            return content()
        }
    }

    func produce(_ position: Int) -> StaticGridConstructionProbe {
        constructionOrder.append(position)
        return StaticGridConstructionProbe(position: position)
    }
}

private struct StaticGridConstructionProbe: View {
    let position: Int

    var body: some View {
        EmptyView()
    }
}

private struct StaticIdentifiableValue: Identifiable {
    let id: String
    let position: Int
}

private struct StaticExplicitIDValue {
    let id: Int
    let position: Int
}
