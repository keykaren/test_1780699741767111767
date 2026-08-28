#if os(macOS)
import AppKit
import Combine
import SwiftUI
@testable import Grid
import XCTest

@available(macOS 10.15, *)
final class GridItemBoundsHostingTests: XCTestCase {
    private static var retainedWindows: [NSWindow] = []
    private let itemSize = CGSize(width: 100, height: 40)

    func testHostedBoundsFollowUUIDIdentityThroughReorderAndRemoval() throws {
        _ = NSApplication.shared
        let first = HostedItem(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!)
        let second = HostedItem(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!)
        let third = HostedItem(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000C3")!)
        let fourth = HostedItem(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000D4")!)
        let model = HostedGridModel(items: [first, second, third, fourth])
        let recorder = HostedBoundsRecorder()
        let rootView = HostedGridView(model: model, recorder: recorder)
        let hostingView = NSHostingView(rootView: rootView)
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 200, height: 80),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.orderFrontRegardless()
        Self.retainedWindows.append(window)

        let initial = try waitForStablePreferences(
            recorder: recorder,
            items: model.items,
            description: "initial UUID bounds"
        )
        assertParallelAndVisiblePreferences(initial)
        XCTAssertEqual(initial.keyed[id: first.id], frame(at: 0))
        XCTAssertEqual(initial.keyed[id: fourth.id], frame(at: 3))

        let reorderedItems = [fourth, second, first, third]
        let reorderedExpectation = prepareStablePreferencesExpectation(
            recorder: recorder,
            items: reorderedItems,
            description: "reordered UUID bounds"
        )
        model.items = reorderedItems
        wait(for: [reorderedExpectation], timeout: 5)
        let reordered = try XCTUnwrap(recorder.snapshot)
        assertParallelAndVisiblePreferences(reordered)
        XCTAssertEqual(reordered.keyed[id: fourth.id], frame(at: 0))
        XCTAssertEqual(reordered.keyed[id: first.id], frame(at: 2))
        XCTAssertNotEqual(initial.keyed[id: first.id], reordered.keyed[id: first.id])

        let remainingItems = [fourth, first, third]
        let removalExpectation = prepareStablePreferencesExpectation(
            recorder: recorder,
            items: remainingItems,
            description: "bounds after removal"
        )
        model.items = remainingItems
        wait(for: [removalExpectation], timeout: 5)
        let afterRemoval = try XCTUnwrap(recorder.snapshot)
        assertParallelAndVisiblePreferences(afterRemoval)
        XCTAssertNil(afterRemoval.keyed[id: second.id])
        XCTAssertEqual(afterRemoval.keyed[id: first.id], frame(at: 1))
    }

    func testEveryInitializerEmitsItsGridIdentity() {
        _ = NSApplication.shared
        let explicitIDs = [
            UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "20000000-0000-0000-0000-000000000002")!
        ]
        let expectedIDs: [AnyHashable] = [
            AnyHashable("identifiable-a"), AnyHashable("identifiable-b"),
            AnyHashable(explicitIDs[0]), AnyHashable(explicitIDs[1]),
            AnyHashable(10), AnyHashable(11),
            AnyHashable(0), AnyHashable(1)
        ]
        let recorder = HostedInitializerIdentityRecorder()
        let emittedExpectation = expectation(description: "all initializer identities emitted")
        recorder.expect(ids: expectedIDs, expectation: emittedExpectation)
        let hostingView = NSHostingView(rootView: HostedInitializerIdentityView(
            explicitIDs: explicitIDs,
            recorder: recorder
        ))
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 100, height: 80),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.orderFrontRegardless()
        Self.retainedWindows.append(window)

        wait(for: [emittedExpectation], timeout: 5)
        XCTAssertEqual(recorder.ids, expectedIDs)
    }

    private func assertParallelAndVisiblePreferences(_ snapshot: HostedBoundsRecorder.Snapshot) {
        XCTAssertEqual(snapshot.keyed.items.count, snapshot.legacy.count)
        XCTAssertEqual(snapshot.keyed.items.map { $0.bounds }, snapshot.legacy)
        XCTAssertEqual(snapshot.keyed, snapshot.visible)
    }

    private func waitForStablePreferences(
        recorder: HostedBoundsRecorder,
        items: [HostedItem],
        description: String
    ) throws -> HostedBoundsRecorder.Snapshot {
        let expectation = prepareStablePreferencesExpectation(
            recorder: recorder,
            items: items,
            description: description
        )
        wait(for: [expectation], timeout: 5)
        return try XCTUnwrap(recorder.snapshot)
    }

    private func prepareStablePreferencesExpectation(
        recorder: HostedBoundsRecorder,
        items: [HostedItem],
        description: String
    ) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        recorder.expect(
            ids: items.map { AnyHashable($0.id) },
            frames: items.indices.map(frame(at:)),
            expectation: expectation
        )
        return expectation
    }

    private func frame(at index: Int) -> CGRect {
        CGRect(
            x: CGFloat(index % 2) * itemSize.width,
            y: CGFloat(index / 2) * itemSize.height,
            width: itemSize.width,
            height: itemSize.height
        )
    }
}

@available(macOS 10.15, *)
private struct HostedInitializerIdentityView: View {
    let explicitIDs: [UUID]
    let recorder: HostedInitializerIdentityRecorder

    var identifiableItems: [HostedStringIDItem] {
        [
            HostedStringIDItem(id: "identifiable-a"),
            HostedStringIDItem(id: "identifiable-b")
        ]
    }

    var explicitItems: [HostedExplicitIDItem] {
        explicitIDs.map { HostedExplicitIDItem(key: $0) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Grid(identifiableItems) { _ in Color.clear }
                .frame(width: 100, height: 20)
            Grid(explicitItems, id: \.key) { _ in Color.clear }
                .frame(width: 100, height: 20)
            Grid(10..<12) { _ in Color.clear }
                .frame(width: 100, height: 20)
            makeHostedStaticIdentityGrid()
                .frame(width: 100, height: 20)
        }
        .onPreferenceChange(GridItemBoundsByIDPreferencesKey.self) {
            self.recorder.receive($0)
        }
        .gridStyle(ModularGridStyle(columns: 2, rows: .fixed(20), spacing: 0))
    }
}

@available(macOS 10.15, *)
private struct HostedStringIDItem: Identifiable {
    let id: String
}

@available(macOS 10.15, *)
private struct HostedExplicitIDItem {
    let key: UUID
}

@available(macOS 10.15, *)
private final class HostedInitializerIdentityRecorder {
    private var expectedIDs: [AnyHashable] = []
    private var pendingExpectation: XCTestExpectation?
    private(set) var ids: [AnyHashable] = []

    func expect(ids: [AnyHashable], expectation: XCTestExpectation) {
        expectedIDs = ids
        pendingExpectation = expectation
        fulfillIfExpected()
    }

    func receive(_ preferences: GridItemBoundsPreferences) {
        ids = preferences.items.map { $0.id }
        fulfillIfExpected()
    }

    private func fulfillIfExpected() {
        guard ids == expectedIDs, let expectation = pendingExpectation else { return }
        pendingExpectation = nil
        expectation.fulfill()
    }
}

@available(macOS 10.15, *)
private struct HostedItem: Identifiable, Equatable {
    let id: UUID
}

@available(macOS 10.15, *)
private final class HostedGridModel: ObservableObject {
    @Published var items: [HostedItem]

    init(items: [HostedItem]) {
        self.items = items
    }
}

@available(macOS 10.15, *)
private struct HostedGridView: View {
    @ObservedObject var model: HostedGridModel
    let recorder: HostedBoundsRecorder

    var body: some View {
        Grid(model.items) { item in
            Rectangle()
                .foregroundColor(.blue)
                .background(HostedVisibleBoundsReporter(id: item.id))
        }
        .frame(width: 200, height: 80, alignment: .topLeading)
        .coordinateSpace(name: HostedVisibleBoundsReporter.coordinateSpaceName)
        .onPreferenceChange(GridItemBoundsByIDPreferencesKey.self) {
            self.recorder.receive(keyed: $0)
        }
        .onPreferenceChange(GridItemBoundsPreferencesKey.self) {
            self.recorder.receive(legacy: $0)
        }
        .onPreferenceChange(HostedVisibleBoundsPreferencesKey.self) {
            self.recorder.receive(visible: $0)
        }
        .gridStyle(ModularGridStyle(columns: 2, rows: .fixed(40), spacing: 0))
    }
}

@available(macOS 10.15, *)
private struct HostedVisibleBoundsReporter: View {
    static let coordinateSpaceName = "GridItemBoundsHostingTests.grid"

    let id: UUID

    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: HostedVisibleBoundsPreferencesKey.self,
                value: GridItemBoundsPreferences(items: [
                    .init(
                        id: AnyHashable(self.id),
                        bounds: geometry.frame(in: .named(Self.coordinateSpaceName))
                    )
                ])
            )
        }
    }
}

@available(macOS 10.15, *)
private struct HostedVisibleBoundsPreferencesKey: PreferenceKey {
    static var defaultValue = GridItemBoundsPreferences()

    static func reduce(
        value: inout GridItemBoundsPreferences,
        nextValue: () -> GridItemBoundsPreferences
    ) {
        value = GridItemBoundsPreferences(items: value.items + nextValue().items)
    }
}

@available(macOS 10.15, *)
private final class HostedBoundsRecorder {
    struct Snapshot {
        let keyed: GridItemBoundsPreferences
        let legacy: [CGRect]
        let visible: GridItemBoundsPreferences
    }

    private var keyed: GridItemBoundsPreferences?
    private var legacy: [CGRect]?
    private var visible: GridItemBoundsPreferences?
    private var expectedIDs: [AnyHashable] = []
    private var expectedFrames: [CGRect] = []
    private var pendingExpectation: XCTestExpectation?

    var snapshot: Snapshot? {
        guard let keyed = keyed, let legacy = legacy, let visible = visible else {
            return nil
        }
        return Snapshot(keyed: keyed, legacy: legacy, visible: visible)
    }

    func expect(ids: [AnyHashable], frames: [CGRect], expectation: XCTestExpectation) {
        expectedIDs = ids
        expectedFrames = frames
        pendingExpectation = expectation
        fulfillIfStable()
    }

    func receive(keyed: GridItemBoundsPreferences) {
        self.keyed = keyed
        fulfillIfStable()
    }

    func receive(legacy: [CGRect]) {
        self.legacy = legacy
        fulfillIfStable()
    }

    func receive(visible: GridItemBoundsPreferences) {
        self.visible = visible
        fulfillIfStable()
    }

    private func fulfillIfStable() {
        guard let expectation = pendingExpectation, let snapshot = snapshot else { return }
        let keyedIDs = snapshot.keyed.items.map { $0.id }
        let keyedFrames = snapshot.keyed.items.map { $0.bounds }
        let visibleIDs = snapshot.visible.items.map { $0.id }
        let visibleFrames = snapshot.visible.items.map { $0.bounds }

        guard keyedIDs == expectedIDs,
              keyedFrames == expectedFrames,
              snapshot.legacy == expectedFrames,
              visibleIDs == expectedIDs,
              visibleFrames == expectedFrames else { return }

        pendingExpectation = nil
        expectation.fulfill()
    }
}
#endif
