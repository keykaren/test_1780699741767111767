#if os(macOS)
import AppKit
import Combine
import enum SwiftUI.Axis
import struct SwiftUI.AnyView
import struct SwiftUI.Color
import struct SwiftUI.GeometryReader
import class SwiftUI.NSHostingView
import struct SwiftUI.ObservedObject
import protocol SwiftUI.PreferenceKey
import struct SwiftUI.Rectangle
import protocol SwiftUI.View
@testable import Grid
import XCTest

@available(macOS 10.15, *)
final class IndependentSpacingHostingTests: XCTestCase {
    private static var retainedWindows: [NSWindow] = []

    func testRuntimeSpacingUpdatesForEveryStyleAndAxis() {
        _ = NSApplication.shared

        for kind in [HostedIndependentStyleKind.modular, .staggered] {
            for axis in [Axis.vertical, Axis.horizontal] {
                assertRuntimeSpacingUpdates(kind: kind, axis: axis)
            }
        }
    }

    private func assertRuntimeSpacingUpdates(
        kind: HostedIndependentStyleKind,
        axis: Axis,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let model = HostedIndependentSpacingModel(axis: axis)
        let recorder = HostedIndependentSpacingRecorder()
        let rootView = HostedIndependentSpacingView(kind: kind, model: model, recorder: recorder)
        let hostingView = NSHostingView(rootView: rootView)
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 230, height: 230),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.orderFrontRegardless()
        Self.retainedWindows.append(window)

        waitForFrames(
            recorder: recorder,
            frames: frames(axis: axis, crossAxisSpacing: 30, mainAxisSpacing: 7),
            description: "initial \(kind) \(axis) spacing",
            file: file,
            line: line
        )

        let crossExpectation = prepareFramesExpectation(
            recorder: recorder,
            frames: frames(axis: axis, crossAxisSpacing: 10, mainAxisSpacing: 7),
            description: "updated \(kind) \(axis) cross-axis spacing"
        )
        model.setCrossAxisSpacing(10, for: kind)
        wait(for: [crossExpectation], timeout: 5)
        assertSnapshot(
            recorder.snapshot,
            frames: frames(axis: axis, crossAxisSpacing: 10, mainAxisSpacing: 7),
            file: file,
            line: line
        )

        let mainExpectation = prepareFramesExpectation(
            recorder: recorder,
            frames: frames(axis: axis, crossAxisSpacing: 10, mainAxisSpacing: 15),
            description: "updated \(kind) \(axis) main-axis spacing"
        )
        model.setMainAxisSpacing(15, for: kind)
        wait(for: [mainExpectation], timeout: 5)
        assertSnapshot(
            recorder.snapshot,
            frames: frames(axis: axis, crossAxisSpacing: 10, mainAxisSpacing: 15),
            file: file,
            line: line
        )

        let legacyExpectation = prepareFramesExpectation(
            recorder: recorder,
            frames: frames(axis: axis, crossAxisSpacing: 30, mainAxisSpacing: 30),
            description: "updated \(kind) \(axis) uniform spacing"
        )
        model.setUniformSpacing(30, for: kind)
        wait(for: [legacyExpectation], timeout: 5)
        assertSnapshot(
            recorder.snapshot,
            frames: frames(axis: axis, crossAxisSpacing: 30, mainAxisSpacing: 30),
            file: file,
            line: line
        )
    }

    private func waitForFrames(
        recorder: HostedIndependentSpacingRecorder,
        frames: [CGRect],
        description: String,
        file: StaticString,
        line: UInt
    ) {
        let expectation = prepareFramesExpectation(
            recorder: recorder,
            frames: frames,
            description: description
        )
        wait(for: [expectation], timeout: 5)
        assertSnapshot(recorder.snapshot, frames: frames, file: file, line: line)
    }

    private func prepareFramesExpectation(
        recorder: HostedIndependentSpacingRecorder,
        frames: [CGRect],
        description: String
    ) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        recorder.expect(
            ids: (0..<4).map { AnyHashable($0) },
            frames: frames,
            expectation: expectation
        )
        return expectation
    }

    private func assertSnapshot(
        _ snapshot: HostedIndependentSpacingRecorder.Snapshot?,
        frames: [CGRect],
        file: StaticString,
        line: UInt
    ) {
        guard let snapshot = snapshot else {
            XCTFail("Expected a complete bounds snapshot", file: file, line: line)
            return
        }
        let ids = (0..<4).map { AnyHashable($0) }
        XCTAssertEqual(snapshot.keyed.items.map { $0.id }, ids, file: file, line: line)
        XCTAssertEqual(snapshot.keyed.items.map { $0.bounds }, frames, file: file, line: line)
        XCTAssertEqual(snapshot.legacy, frames, file: file, line: line)
        XCTAssertEqual(snapshot.visible.items.map { $0.id }, ids, file: file, line: line)
        XCTAssertEqual(snapshot.visible.items.map { $0.bounds }, frames, file: file, line: line)
    }

    private func frames(
        axis: Axis,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat
    ) -> [CGRect] {
        let crossLength = (CGFloat(230) - crossAxisSpacing) / 2
        return (0..<4).map { index in
            let track = CGFloat(index % 2)
            let row = CGFloat(index / 2)
            if axis == .vertical {
                return CGRect(
                    x: track * (crossLength + crossAxisSpacing),
                    y: row * (40 + mainAxisSpacing),
                    width: crossLength,
                    height: 40
                )
            }
            return CGRect(
                x: row * (40 + mainAxisSpacing),
                y: track * (crossLength + crossAxisSpacing),
                width: 40,
                height: crossLength
            )
        }
    }
}

@available(macOS 10.15, *)
private enum HostedIndependentStyleKind: CustomStringConvertible {
    case modular
    case staggered

    var description: String {
        switch self {
        case .modular:
            return "modular"
        case .staggered:
            return "staggered"
        }
    }
}

@available(macOS 10.15, *)
private final class HostedIndependentSpacingModel: ObservableObject {
    @Published var modularStyle: ModularGridStyle
    @Published var staggeredStyle: StaggeredGridStyle

    init(axis: Axis) {
        if axis == .vertical {
            modularStyle = ModularGridStyle(
                axis,
                columns: 2,
                rows: .fixed(40),
                crossAxisSpacing: 30,
                mainAxisSpacing: 7
            )
        } else {
            modularStyle = ModularGridStyle(
                axis,
                columns: .fixed(40),
                rows: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 7
            )
        }
        staggeredStyle = StaggeredGridStyle(
            axis,
            tracks: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )
    }

    func setCrossAxisSpacing(_ spacing: CGFloat, for kind: HostedIndependentStyleKind) {
        switch kind {
        case .modular:
            var style = modularStyle
            style.crossAxisSpacing = spacing
            modularStyle = style
        case .staggered:
            var style = staggeredStyle
            style.crossAxisSpacing = spacing
            staggeredStyle = style
        }
    }

    func setMainAxisSpacing(_ spacing: CGFloat, for kind: HostedIndependentStyleKind) {
        switch kind {
        case .modular:
            var style = modularStyle
            style.mainAxisSpacing = spacing
            modularStyle = style
        case .staggered:
            var style = staggeredStyle
            style.mainAxisSpacing = spacing
            staggeredStyle = style
        }
    }

    func setUniformSpacing(_ spacing: CGFloat, for kind: HostedIndependentStyleKind) {
        switch kind {
        case .modular:
            var style = modularStyle
            style.spacing = spacing
            modularStyle = style
        case .staggered:
            var style = staggeredStyle
            style.spacing = spacing
            staggeredStyle = style
        }
    }
}

@available(macOS 10.15, *)
private struct HostedIndependentSpacingView: View {
    let kind: HostedIndependentStyleKind
    @ObservedObject var model: HostedIndependentSpacingModel
    let recorder: HostedIndependentSpacingRecorder

    var body: some View {
        content()
    }

    private func content() -> AnyView {
        switch kind {
        case .modular:
            return AnyView(grid().gridStyle(model.modularStyle))
        case .staggered:
            return AnyView(grid().gridStyle(model.staggeredStyle))
        }
    }

    private func grid() -> some View {
        Grid(0..<4) { index in
            HostedIndependentSpacingItem(axis: self.model.modularStyle.axis, id: index)
        }
        .frame(width: 230, height: 230, alignment: .topLeading)
        .coordinateSpace(name: HostedIndependentVisibleBoundsReporter.coordinateSpaceName)
        .onPreferenceChange(GridItemBoundsByIDPreferencesKey.self) {
            self.recorder.receive(keyed: $0)
        }
        .onPreferenceChange(GridItemBoundsPreferencesKey.self) {
            self.recorder.receive(legacy: $0)
        }
        .onPreferenceChange(HostedIndependentVisibleBoundsPreferencesKey.self) {
            self.recorder.receive(visible: $0)
        }
    }
}

@available(macOS 10.15, *)
private struct HostedIndependentSpacingItem: View {
    let axis: Axis
    let id: Int

    var body: some View {
        content()
    }

    private func content() -> AnyView {
        if axis == .vertical {
            return AnyView(
                Rectangle()
                    .frame(height: 40)
                    .background(HostedIndependentVisibleBoundsReporter(id: id))
            )
        }
        return AnyView(
            Rectangle()
                .frame(width: 40)
                .background(HostedIndependentVisibleBoundsReporter(id: id))
        )
    }
}

@available(macOS 10.15, *)
private struct HostedIndependentVisibleBoundsReporter: View {
    static let coordinateSpaceName = "IndependentSpacingHostingTests.grid"

    let id: Int

    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: HostedIndependentVisibleBoundsPreferencesKey.self,
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
private struct HostedIndependentVisibleBoundsPreferencesKey: PreferenceKey {
    static var defaultValue = GridItemBoundsPreferences()

    static func reduce(
        value: inout GridItemBoundsPreferences,
        nextValue: () -> GridItemBoundsPreferences
    ) {
        value = GridItemBoundsPreferences(items: value.items + nextValue().items)
    }
}

@available(macOS 10.15, *)
private final class HostedIndependentSpacingRecorder {
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
        guard snapshot.keyed.items.map({ $0.id }) == expectedIDs,
              snapshot.keyed.items.map({ $0.bounds }) == expectedFrames,
              snapshot.legacy == expectedFrames,
              snapshot.visible.items.map({ $0.id }) == expectedIDs,
              snapshot.visible.items.map({ $0.bounds }) == expectedFrames else { return }

        pendingExpectation = nil
        expectation.fulfill()
    }
}
#endif
