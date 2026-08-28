import enum SwiftUI.Axis
@testable import Grid
import XCTest

final class IndependentSpacingLayoutTests: XCTestCase {
    func testUniformSpacingExactlyMatchesLegacyLayoutForEveryTrackKindStyleAndAxis() {
        let trackCases: [Tracks] = [.count(3), .fixed(70), .min(70)]
        let source = measuredPreferences(axis: .vertical, lengths: [31, 52, 43, 64, 25, 36, 47])
        let availableSize = CGSize(width: 320, height: 280)
        let spacing: CGFloat = 13

        for axis in [Axis.vertical, Axis.horizontal] {
            for tracks in trackCases {
                let modularSource = GridPreferences(items: source.items.map {
                    GridPreferences.Item(id: $0.id, bounds: $0.bounds)
                })
                let modularLegacy = ModularGridStyle(
                    axis,
                    columns: tracks,
                    rows: tracks,
                    spacing: spacing
                )
                let modularIndependent = ModularGridStyle(
                    axis,
                    columns: tracks,
                    rows: tracks,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing
                )
                let expectedModular = legacyModularLayout(
                    axis: axis,
                    columns: tracks,
                    rows: tracks,
                    spacing: spacing,
                    preferences: modularSource,
                    size: availableSize
                )
                XCTAssertEqual(
                    transformed(modularLegacy, preferences: modularSource, size: availableSize),
                    expectedModular
                )
                XCTAssertEqual(
                    transformed(modularIndependent, preferences: modularSource, size: availableSize),
                    expectedModular
                )

                let staggeredSource = measuredPreferences(
                    axis: axis,
                    lengths: [31, 52, 43, 64, 25, 36, 47]
                )
                let staggeredLegacy = StaggeredGridStyle(axis, tracks: tracks, spacing: spacing)
                let staggeredIndependent = StaggeredGridStyle(
                    axis,
                    tracks: tracks,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing
                )
                let expectedStaggered = legacyStaggeredLayout(
                    axis: axis,
                    tracks: tracks,
                    spacing: spacing,
                    preferences: staggeredSource,
                    size: availableSize
                )
                XCTAssertEqual(
                    transformed(staggeredLegacy, preferences: staggeredSource, size: availableSize),
                    expectedStaggered
                )
                XCTAssertEqual(
                    transformed(staggeredIndependent, preferences: staggeredSource, size: availableSize),
                    expectedStaggered
                )
            }
        }
    }

    func testVerticalModularGeometryUsesIndependentSpacingWithoutTrailingGaps() {
        let style = ModularGridStyle(
            .vertical,
            columns: 2,
            rows: .fixed(40),
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )
        let preferences = transformed(
            style,
            preferences: emptyMeasuredPreferences(count: 6),
            size: CGSize(width: 230, height: 400)
        )

        XCTAssertEqual(preferences, GridPreferences(
            size: CGSize(width: 230, height: 134),
            items: [
                item(0, x: 0, y: 0, width: 100, height: 40),
                item(1, x: 130, y: 0, width: 100, height: 40),
                item(2, x: 0, y: 47, width: 100, height: 40),
                item(3, x: 130, y: 47, width: 100, height: 40),
                item(4, x: 0, y: 94, width: 100, height: 40),
                item(5, x: 130, y: 94, width: 100, height: 40)
            ]
        ))
    }

    func testHorizontalModularGeometryTransposesIndependentSpacing() {
        let style = ModularGridStyle(
            .horizontal,
            columns: .fixed(40),
            rows: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )
        let preferences = transformed(
            style,
            preferences: emptyMeasuredPreferences(count: 6),
            size: CGSize(width: 400, height: 230)
        )

        XCTAssertEqual(preferences, GridPreferences(
            size: CGSize(width: 134, height: 230),
            items: [
                item(0, x: 0, y: 0, width: 40, height: 100),
                item(1, x: 0, y: 130, width: 40, height: 100),
                item(2, x: 47, y: 0, width: 40, height: 100),
                item(3, x: 47, y: 130, width: 40, height: 100),
                item(4, x: 94, y: 0, width: 40, height: 100),
                item(5, x: 94, y: 130, width: 40, height: 100)
            ]
        ))
    }

    func testVerticalStaggeredGeometryPreservesLengthsAndUsesGapsForShortestTrack() {
        let style = StaggeredGridStyle(
            .vertical,
            tracks: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )
        let preferences = transformed(
            style,
            preferences: measuredPreferences(axis: .vertical, lengths: [50, 20, 60, 10, 15]),
            size: CGSize(width: 230, height: 400)
        )

        XCTAssertEqual(preferences, GridPreferences(
            size: CGSize(width: 230, height: 89),
            items: [
                item(0, x: 0, y: 0, width: 100, height: 50),
                item(1, x: 130, y: 0, width: 100, height: 20),
                item(2, x: 130, y: 27, width: 100, height: 60),
                item(3, x: 0, y: 57, width: 100, height: 10),
                item(4, x: 0, y: 74, width: 100, height: 15)
            ]
        ))
    }

    func testHorizontalStaggeredGeometryTransposesLengthsAndShortestTrackAssignment() {
        let style = StaggeredGridStyle(
            .horizontal,
            tracks: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )
        let preferences = transformed(
            style,
            preferences: measuredPreferences(axis: .horizontal, lengths: [50, 20, 60, 10, 15]),
            size: CGSize(width: 400, height: 230)
        )

        XCTAssertEqual(preferences, GridPreferences(
            size: CGSize(width: 89, height: 230),
            items: [
                item(0, x: 0, y: 0, width: 50, height: 100),
                item(1, x: 0, y: 130, width: 20, height: 100),
                item(2, x: 27, y: 130, width: 60, height: 100),
                item(3, x: 57, y: 0, width: 10, height: 100),
                item(4, x: 74, y: 0, width: 15, height: 100)
            ]
        ))
    }

    func testAdaptiveCountAndCrossAxisSizeIgnoreMainAxisSpacing() {
        let trackCases: [(Tracks, CGFloat)] = [(.fixed(100), 100), (.min(100), 100)]
        for axis in [Axis.vertical, Axis.horizontal] {
            for trackCase in trackCases {
                for mainAxisSpacing in [CGFloat(-50), 0, 7, 1_000] {
                    assertEveryStyle(
                        axis: axis,
                        tracks: trackCase.0,
                        availableCrossLength: 220,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: mainAxisSpacing,
                        expectedTracksCount: 2,
                        expectedCrossLength: trackCase.1
                    )
                }
            }

            assertEveryStyle(
                axis: axis,
                tracks: .min(100),
                availableCrossLength: 250,
                crossAxisSpacing: 20,
                mainAxisSpacing: 999,
                expectedTracksCount: 2,
                expectedCrossLength: 115
            )
        }
    }

    func testAdaptiveCrossAxisSpacingBoundariesAreIndependent() {
        let exact: CGFloat = 220
        for axis in [Axis.vertical, Axis.horizontal] {
            for tracks in [Tracks.fixed(100), Tracks.min(100)] {
                assertEveryStyle(
                    axis: axis,
                    tracks: tracks,
                    availableCrossLength: exact,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 37,
                    expectedTracksCount: 2,
                    expectedCrossLength: 100
                )
                assertEveryStyle(
                    axis: axis,
                    tracks: tracks,
                    availableCrossLength: exact.nextDown,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: -100,
                    expectedTracksCount: 1,
                    expectedCrossLength: tracks == .fixed(100) ? 100 : exact.nextDown
                )
                assertEveryStyle(
                    axis: axis,
                    tracks: tracks,
                    availableCrossLength: exact,
                    crossAxisSpacing: CGFloat(20).nextUp,
                    mainAxisSpacing: 0,
                    expectedTracksCount: 1,
                    expectedCrossLength: tracks == .fixed(100) ? 100 : exact
                )
            }
        }
    }

    func testFractionalZeroLargeAndNegativeCrossAxisSpacing() {
        for axis in [Axis.vertical, Axis.horizontal] {
            assertEveryStyle(
                axis: axis,
                tracks: .fixed(10.1),
                availableCrossLength: 40.3,
                crossAxisSpacing: 20.1,
                mainAxisSpacing: 6,
                expectedTracksCount: 2,
                expectedCrossLength: 10.1
            )
            assertEveryStyle(
                axis: axis,
                tracks: .fixed(100),
                availableCrossLength: 300,
                crossAxisSpacing: 0,
                mainAxisSpacing: 6,
                expectedTracksCount: 3,
                expectedCrossLength: 100
            )
            assertEveryStyle(
                axis: axis,
                tracks: .min(100),
                availableCrossLength: 250,
                crossAxisSpacing: 500,
                mainAxisSpacing: 6,
                expectedTracksCount: 1,
                expectedCrossLength: 250
            )
            assertEveryStyle(
                axis: axis,
                tracks: .fixed(100),
                availableCrossLength: 300,
                crossAxisSpacing: -20,
                mainAxisSpacing: 6,
                expectedTracksCount: 3,
                expectedCrossLength: 100
            )
        }
    }

    func testEachSpacingDirectionChangesOnlyItsOwnGeometry() {
        for axis in [Axis.vertical, Axis.horizontal] {
            let initial = transformed(
                staggeredStyle(axis: axis, crossAxisSpacing: 30, mainAxisSpacing: 7),
                preferences: measuredPreferences(axis: axis, lengths: [40, 40, 40, 40]),
                size: availableSize(axis: axis, crossLength: 230, mainLength: 230)
            )
            let crossChanged = transformed(
                staggeredStyle(axis: axis, crossAxisSpacing: 10, mainAxisSpacing: 7),
                preferences: measuredPreferences(axis: axis, lengths: [40, 40, 40, 40]),
                size: availableSize(axis: axis, crossLength: 230, mainLength: 230)
            )
            let mainChanged = transformed(
                staggeredStyle(axis: axis, crossAxisSpacing: 30, mainAxisSpacing: 15),
                preferences: measuredPreferences(axis: axis, lengths: [40, 40, 40, 40]),
                size: availableSize(axis: axis, crossLength: 230, mainLength: 230)
            )

            XCTAssertEqual(
                initial.items.map { mainOrigin($0.bounds, axis: axis) },
                crossChanged.items.map { mainOrigin($0.bounds, axis: axis) }
            )
            XCTAssertEqual(
                initial.items.map { crossOrigin($0.bounds, axis: axis) },
                mainChanged.items.map { crossOrigin($0.bounds, axis: axis) }
            )
            XCTAssertEqual(
                initial.items.map { crossLength($0.bounds, axis: axis) },
                mainChanged.items.map { crossLength($0.bounds, axis: axis) }
            )
            XCTAssertNotEqual(initial.items.map { crossOrigin($0.bounds, axis: axis) }, crossChanged.items.map { crossOrigin($0.bounds, axis: axis) })
            XCTAssertNotEqual(initial.items.map { mainOrigin($0.bounds, axis: axis) }, mainChanged.items.map { mainOrigin($0.bounds, axis: axis) })
        }
    }

    func testNegativeMainAxisSpacingOverlapsWithoutTrailingSpacing() {
        for axis in [Axis.vertical, Axis.horizontal] {
            let preferences = transformed(
                StaggeredGridStyle(
                    axis,
                    tracks: 1,
                    crossAxisSpacing: -200,
                    mainAxisSpacing: -10
                ),
                preferences: measuredPreferences(axis: axis, lengths: [40, 40]),
                size: availableSize(axis: axis, crossLength: 100, mainLength: 100)
            )

            XCTAssertEqual(preferences.items.map { crossOrigin($0.bounds, axis: axis) }, [0, 0])
            XCTAssertEqual(preferences.items.map { mainOrigin($0.bounds, axis: axis) }, [0, 30])
            XCTAssertEqual(mainAggregateLength(preferences.size, axis: axis), 70)
        }
    }

    func testEmptyOneTrackAndOneItemLayoutsHaveNoExteriorOrTrailingSpacing() {
        for axis in [Axis.vertical, Axis.horizontal] {
            let styles: [AnyGridStyle] = [
                AnyGridStyle(modularStyle(
                    axis: axis,
                    tracks: 1,
                    crossAxisSpacing: 400,
                    mainAxisSpacing: 300
                )),
                AnyGridStyle(StaggeredGridStyle(
                    axis,
                    tracks: 1,
                    crossAxisSpacing: 400,
                    mainAxisSpacing: 300
                ))
            ]

            for style in styles {
                let empty = style.transform(
                    GridPreferences(items: []),
                    in: availableSize(axis: axis, crossLength: 100, mainLength: 100)
                )
                XCTAssertEqual(empty, GridPreferences(items: []))

                let one = style.transform(
                    measuredPreferences(axis: axis, lengths: [40]),
                    in: availableSize(axis: axis, crossLength: 100, mainLength: 100)
                )
                XCTAssertEqual(one.items.count, 1)
                XCTAssertEqual(one.items[0].id, AnyHashable(0))
                XCTAssertEqual(one.items[0].bounds.origin, .zero)
                XCTAssertEqual(crossLength(one.items[0].bounds, axis: axis), 100)
                XCTAssertEqual(mainLength(one.items[0].bounds, axis: axis), 40)
                XCTAssertEqual(crossAggregateLength(one.size, axis: axis), 100)
                XCTAssertEqual(mainAggregateLength(one.size, axis: axis), 40)
            }
        }
    }

    private func assertEveryStyle(
        axis: Axis,
        tracks: Tracks,
        availableCrossLength: CGFloat,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat,
        expectedTracksCount: Int,
        expectedCrossLength: CGFloat,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            tracksCount(
                tracks: tracks,
                spacing: crossAxisSpacing,
                availableLength: availableCrossLength
            ),
            expectedTracksCount,
            file: file,
            line: line
        )
        let itemCount = expectedTracksCount * 2
        let itemMainLength = max(40, -mainAxisSpacing + 10)
        let source = measuredPreferences(
            axis: axis,
            lengths: Array(repeating: itemMainLength, count: itemCount)
        )
        let size = availableSize(axis: axis, crossLength: availableCrossLength, mainLength: 500)
        let layouts = [
            transformed(
                modularStyle(
                    axis: axis,
                    tracks: tracks,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    mainItemLength: itemMainLength
                ),
                preferences: source,
                size: size
            ),
            transformed(
                StaggeredGridStyle(
                    axis,
                    tracks: tracks,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing
                ),
                preferences: source,
                size: size
            )
        ]

        for layout in layouts {
            XCTAssertEqual(layout.items.count, itemCount, file: file, line: line)
            XCTAssertEqual(layout.items.map { $0.id }, (0..<itemCount).map { AnyHashable($0) }, file: file, line: line)
            for index in 0..<expectedTracksCount {
                XCTAssertEqual(
                    crossOrigin(layout.items[index].bounds, axis: axis),
                    CGFloat(index) * (expectedCrossLength + crossAxisSpacing),
                    accuracy: 0.000001,
                    file: file,
                    line: line
                )
                XCTAssertEqual(
                    crossLength(layout.items[index].bounds, axis: axis),
                    expectedCrossLength,
                    accuracy: 0.000001,
                    file: file,
                    line: line
                )
            }
            XCTAssertEqual(
                crossOrigin(layout.items[expectedTracksCount].bounds, axis: axis),
                0,
                accuracy: 0.000001,
                file: file,
                line: line
            )
        }
    }

    private func transformed<Style: GridStyle>(
        _ style: Style,
        preferences: GridPreferences,
        size: CGSize
    ) -> GridPreferences {
        var result = preferences
        style.transform(preferences: &result, in: size)
        return result
    }

    private func modularStyle(
        axis: Axis,
        tracks: Tracks,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat,
        mainItemLength: CGFloat = 40
    ) -> ModularGridStyle {
        if axis == .vertical {
            return ModularGridStyle(
                axis,
                columns: tracks,
                rows: .fixed(mainItemLength),
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing
            )
        }
        return ModularGridStyle(
            axis,
            columns: .fixed(mainItemLength),
            rows: tracks,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing
        )
    }

    private func staggeredStyle(
        axis: Axis,
        crossAxisSpacing: CGFloat,
        mainAxisSpacing: CGFloat
    ) -> StaggeredGridStyle {
        StaggeredGridStyle(
            axis,
            tracks: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing
        )
    }

    private func legacyModularLayout(
        axis: Axis,
        columns: Tracks,
        rows: Tracks,
        spacing: CGFloat,
        preferences: GridPreferences,
        size: CGSize
    ) -> GridPreferences {
        let count = tracksCount(
            tracks: axis == .vertical ? columns : rows,
            spacing: spacing,
            availableLength: axis == .vertical ? size.width : size.height
        )
        let itemSize = CGSize(
            width: itemLength(tracks: columns, spacing: spacing, availableLength: size.width),
            height: itemLength(tracks: rows, spacing: spacing, availableLength: size.height)
        )
        return legacyLayout(
            axis: axis,
            trackCount: count,
            spacing: spacing,
            preferences: preferences
        ) { _ in itemSize }
    }

    private func legacyStaggeredLayout(
        axis: Axis,
        tracks: Tracks,
        spacing: CGFloat,
        preferences: GridPreferences,
        size: CGSize
    ) -> GridPreferences {
        let availableCrossLength = axis == .vertical ? size.width : size.height
        let count = tracksCount(
            tracks: tracks,
            spacing: spacing,
            availableLength: availableCrossLength
        )
        let computedCrossLength = itemLength(
            tracks: tracks,
            spacing: spacing,
            availableLength: availableCrossLength
        )
        return legacyLayout(
            axis: axis,
            trackCount: count,
            spacing: spacing,
            preferences: preferences
        ) { preference in
            if axis == .vertical {
                return CGSize(width: computedCrossLength, height: preference.bounds.height)
            }
            return CGSize(width: preference.bounds.width, height: computedCrossLength)
        }
    }

    private func legacyLayout(
        axis: Axis,
        trackCount: Int,
        spacing: CGFloat,
        preferences: GridPreferences,
        itemSize: (GridPreferences.Item) -> CGSize
    ) -> GridPreferences {
        var trackLengths = Array(repeating: CGFloat(0), count: trackCount)
        var result = GridPreferences(items: [])
        for preference in preferences.items {
            guard let minimum = trackLengths.min(),
                  let track = trackLengths.firstIndex(of: minimum) else { continue }
            let size = itemSize(preference)
            let x = axis == .vertical ?
                size.width * CGFloat(track) + CGFloat(track) * spacing :
                trackLengths[track]
            let y = axis == .vertical ?
                trackLengths[track] :
                size.height * CGFloat(track) + CGFloat(track) * spacing
            result.merge(with: GridPreferences(items: [
                GridPreferences.Item(
                    id: preference.id,
                    bounds: CGRect(origin: CGPoint(x: x, y: y), size: size)
                )
            ]))
            trackLengths[track] += (axis == .vertical ? size.height : size.width) + spacing
        }
        return result
    }

    private func emptyMeasuredPreferences(count: Int) -> GridPreferences {
        GridPreferences(items: (0..<count).map {
            GridPreferences.Item(id: $0, bounds: .zero)
        })
    }

    private func measuredPreferences(axis: Axis, lengths: [CGFloat]) -> GridPreferences {
        GridPreferences(items: lengths.enumerated().map { index, length in
            GridPreferences.Item(
                id: index,
                bounds: CGRect(
                    origin: .zero,
                    size: axis == .vertical ?
                        CGSize(width: 1, height: length) :
                        CGSize(width: length, height: 1)
                )
            )
        })
    }

    private func item(
        _ id: Int,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> GridPreferences.Item {
        GridPreferences.Item(
            id: id,
            bounds: CGRect(x: x, y: y, width: width, height: height)
        )
    }

    private func availableSize(axis: Axis, crossLength: CGFloat, mainLength: CGFloat) -> CGSize {
        axis == .vertical ?
            CGSize(width: crossLength, height: mainLength) :
            CGSize(width: mainLength, height: crossLength)
    }

    private func crossOrigin(_ bounds: CGRect, axis: Axis) -> CGFloat {
        axis == .vertical ? bounds.origin.x : bounds.origin.y
    }

    private func mainOrigin(_ bounds: CGRect, axis: Axis) -> CGFloat {
        axis == .vertical ? bounds.origin.y : bounds.origin.x
    }

    private func crossLength(_ bounds: CGRect, axis: Axis) -> CGFloat {
        axis == .vertical ? bounds.width : bounds.height
    }

    private func mainLength(_ bounds: CGRect, axis: Axis) -> CGFloat {
        axis == .vertical ? bounds.height : bounds.width
    }

    private func crossAggregateLength(_ size: CGSize, axis: Axis) -> CGFloat {
        axis == .vertical ? size.width : size.height
    }

    private func mainAggregateLength(_ size: CGSize, axis: Axis) -> CGFloat {
        axis == .vertical ? size.height : size.width
    }
}

private struct AnyGridStyle {
    private let transformPreferences: (GridPreferences, CGSize) -> GridPreferences

    init<Style: GridStyle>(_ style: Style) {
        transformPreferences = { preferences, size in
            var result = preferences
            style.transform(preferences: &result, in: size)
            return result
        }
    }

    func transform(_ preferences: GridPreferences, in size: CGSize) -> GridPreferences {
        transformPreferences(preferences, size)
    }
}
