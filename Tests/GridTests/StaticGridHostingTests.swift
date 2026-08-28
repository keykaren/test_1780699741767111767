#if os(macOS)
import AppKit
import struct SwiftUI.AnyView
import struct SwiftUI.Color
import class SwiftUI.NSHostingView
import protocol SwiftUI.PreferenceKey
import struct SwiftUI.Rectangle
import struct SwiftUI.Text
import protocol SwiftUI.View
import struct SwiftUI.ViewBuilder
import struct SwiftUI.VStack
@testable import Grid
import XCTest

@available(macOS 10.15, *)
final class StaticGridHostingTests: XCTestCase {
    private static var retainedWindows: [NSWindow] = []

    func testEveryStaticArityRendersOnceFromItsSingleBuilderEvaluation() {
        _ = NSApplication.shared
        let recorder = HostedStaticGridRecorder()
        let rootView = HostedStaticGridsView(recorder: recorder)
        let initialized = recorder.snapshot

        XCTAssertEqual(initialized.builderInvocations, 9)
        XCTAssertEqual(initialized.constructed.count, 54)
        assertMarkers(initialized.constructed)

        let renderedExpectation = expectation(description: "all static children rendered from one evaluation per arity")
        recorder.expect(rendered: initialized.constructed, expectation: renderedExpectation)

        let hostingView = NSHostingView(rootView: rootView)
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 200, height: 180),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.orderFrontRegardless()
        Self.retainedWindows.append(window)

        wait(for: [renderedExpectation], timeout: 5)

        XCTAssertEqual(recorder.rendered, initialized.constructed)
        XCTAssertEqual(recorder.snapshot, initialized)
        assertMarkers(recorder.rendered)
    }

    private func assertMarkers(
        _ markers: [HostedStaticGridMarker],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectedArities = (2...10).flatMap { arity in
            (0..<arity).map { _ in arity }
        }
        let expectedPositions = (2...10).flatMap { arity in
            Array(0..<arity)
        }
        XCTAssertEqual(markers.map { $0.arity }, expectedArities, file: file, line: line)
        XCTAssertEqual(markers.map { $0.position }, expectedPositions, file: file, line: line)

        for arity in 2...10 {
            let arityMarkers = markers.filter { $0.arity == arity }
            XCTAssertEqual(arityMarkers.count, arity, file: file, line: line)
            XCTAssertEqual(arityMarkers.map { $0.position }, Array(0..<arity), file: file, line: line)
            XCTAssertEqual(Set(arityMarkers.map { $0.evaluationToken }).count, 1, file: file, line: line)
            for position in 0..<arity {
                XCTAssertEqual(arityMarkers.filter { $0.position == position }.count, 1, file: file, line: line)
            }
        }
    }
}

@available(macOS 10.15, *)
private struct HostedStaticGridsView: View {
    let content: AnyView

    init(recorder: HostedStaticGridRecorder) {
        content = AnyView(
            VStack(spacing: 0) {
                Grid(content: recorder.instrument(arity: 2) { token in
                    recorder.marker(arity: 2, position: 0, evaluationToken: token)
                    Text("2-1").background(recorder.marker(arity: 2, position: 1, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 3) { token in
                    recorder.marker(arity: 3, position: 0, evaluationToken: token)
                    Text("3-1").background(recorder.marker(arity: 3, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 3, position: 2, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 4) { token in
                    recorder.marker(arity: 4, position: 0, evaluationToken: token)
                    Text("4-1").background(recorder.marker(arity: 4, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 4, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 4, position: 3, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 5) { token in
                    recorder.marker(arity: 5, position: 0, evaluationToken: token)
                    Text("5-1").background(recorder.marker(arity: 5, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 5, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 5, position: 3, evaluationToken: token))
                    Text("5-4").overlay(recorder.marker(arity: 5, position: 4, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 6) { token in
                    recorder.marker(arity: 6, position: 0, evaluationToken: token)
                    Text("6-1").background(recorder.marker(arity: 6, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 6, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 6, position: 3, evaluationToken: token))
                    Text("6-4").overlay(recorder.marker(arity: 6, position: 4, evaluationToken: token))
                    Color.clear.overlay(recorder.marker(arity: 6, position: 5, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 7) { token in
                    recorder.marker(arity: 7, position: 0, evaluationToken: token)
                    Text("7-1").background(recorder.marker(arity: 7, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 7, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 7, position: 3, evaluationToken: token))
                    Text("7-4").overlay(recorder.marker(arity: 7, position: 4, evaluationToken: token))
                    Color.clear.overlay(recorder.marker(arity: 7, position: 5, evaluationToken: token))
                    Rectangle().overlay(recorder.marker(arity: 7, position: 6, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 8) { token in
                    recorder.marker(arity: 8, position: 0, evaluationToken: token)
                    Text("8-1").background(recorder.marker(arity: 8, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 8, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 8, position: 3, evaluationToken: token))
                    Text("8-4").overlay(recorder.marker(arity: 8, position: 4, evaluationToken: token))
                    Color.clear.overlay(recorder.marker(arity: 8, position: 5, evaluationToken: token))
                    Rectangle().overlay(recorder.marker(arity: 8, position: 6, evaluationToken: token))
                    Text("8-7").background(recorder.marker(arity: 8, position: 7, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 9) { token in
                    recorder.marker(arity: 9, position: 0, evaluationToken: token)
                    Text("9-1").background(recorder.marker(arity: 9, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 9, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 9, position: 3, evaluationToken: token))
                    Text("9-4").overlay(recorder.marker(arity: 9, position: 4, evaluationToken: token))
                    Color.clear.overlay(recorder.marker(arity: 9, position: 5, evaluationToken: token))
                    Rectangle().overlay(recorder.marker(arity: 9, position: 6, evaluationToken: token))
                    Text("9-7").background(recorder.marker(arity: 9, position: 7, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 9, position: 8, evaluationToken: token))
                })
                .frame(width: 200, height: 20)

                Grid(content: recorder.instrument(arity: 10) { token in
                    recorder.marker(arity: 10, position: 0, evaluationToken: token)
                    Text("10-1").background(recorder.marker(arity: 10, position: 1, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 10, position: 2, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 10, position: 3, evaluationToken: token))
                    Text("10-4").overlay(recorder.marker(arity: 10, position: 4, evaluationToken: token))
                    Color.clear.overlay(recorder.marker(arity: 10, position: 5, evaluationToken: token))
                    Rectangle().overlay(recorder.marker(arity: 10, position: 6, evaluationToken: token))
                    Text("10-7").background(recorder.marker(arity: 10, position: 7, evaluationToken: token))
                    Color.clear.background(recorder.marker(arity: 10, position: 8, evaluationToken: token))
                    Rectangle().background(recorder.marker(arity: 10, position: 9, evaluationToken: token))
                })
                .frame(width: 200, height: 20)
            }
            .onPreferenceChange(HostedStaticGridMarkersKey.self) {
                recorder.receive(rendered: $0)
            }
            .gridStyle(ModularGridStyle(columns: 10, rows: .fixed(20), spacing: 0))
        )
    }

    var body: some View {
        content
    }
}

@available(macOS 10.15, *)
private final class HostedStaticGridRecorder {
    struct Snapshot: Equatable {
        let builderInvocations: Int
        let constructed: [HostedStaticGridMarker]
    }

    private var nextEvaluationToken = 0
    private(set) var builderInvocations = 0
    private(set) var constructed: [HostedStaticGridMarker] = []
    private(set) var rendered: [HostedStaticGridMarker] = []
    private var expectedRendered: [HostedStaticGridMarker] = []
    private var pendingExpectation: XCTestExpectation?

    var snapshot: Snapshot {
        Snapshot(builderInvocations: builderInvocations, constructed: constructed)
    }

    func instrument<Content: View>(
        arity: Int,
        @ViewBuilder _ content: @escaping (Int) -> Content
    ) -> () -> Content {
        return {
            self.builderInvocations += 1
            self.nextEvaluationToken += 1
            return content(self.nextEvaluationToken)
        }
    }

    func marker(arity: Int, position: Int, evaluationToken: Int) -> HostedStaticGridMarkerView {
        let marker = HostedStaticGridMarker(
            arity: arity,
            position: position,
            evaluationToken: evaluationToken
        )
        constructed.append(marker)
        return HostedStaticGridMarkerView(marker: marker)
    }

    func expect(rendered: [HostedStaticGridMarker], expectation: XCTestExpectation) {
        expectedRendered = rendered
        pendingExpectation = expectation
        fulfillIfExpected()
    }

    func receive(rendered: [HostedStaticGridMarker]) {
        self.rendered = rendered
        fulfillIfExpected()
    }

    private func fulfillIfExpected() {
        guard rendered == expectedRendered, let expectation = pendingExpectation else { return }
        pendingExpectation = nil
        expectation.fulfill()
    }
}

@available(macOS 10.15, *)
private struct HostedStaticGridMarker: Equatable {
    let arity: Int
    let position: Int
    let evaluationToken: Int
}

@available(macOS 10.15, *)
private struct HostedStaticGridMarkerView: View {
    let marker: HostedStaticGridMarker

    var body: some View {
        Color.clear.preference(key: HostedStaticGridMarkersKey.self, value: [marker])
    }
}

@available(macOS 10.15, *)
private struct HostedStaticGridMarkersKey: PreferenceKey {
    static var defaultValue: [HostedStaticGridMarker] = []

    static func reduce(
        value: inout [HostedStaticGridMarker],
        nextValue: () -> [HostedStaticGridMarker]
    ) {
        value.append(contentsOf: nextValue())
    }
}
#endif
