import enum SwiftUI.Axis
@testable import Grid
import XCTest

final class AdaptiveTrackLayoutTests: XCTestCase {
    func testSpacingAwareBoundariesInEveryStyleAndAxis() {
        let boundaries: [(available: CGFloat, count: Int, minimumLength: CGFloat)] = [
            (0, 1, 0),
            (80, 1, 80),
            (210, 1, 210),
            (219.5, 1, 219.5),
            (220, 2, 100),
            (339.5, 2, 159.75),
            (340, 3, 100)
        ]

        for boundary in boundaries {
            assertEveryGridStyle(
                tracks: .fixed(100),
                spacing: 20,
                availableLength: boundary.available,
                expectedTracksCount: boundary.count,
                expectedTrackLength: 100
            )
            assertEveryGridStyle(
                tracks: .min(100),
                spacing: 20,
                availableLength: boundary.available,
                expectedTracksCount: boundary.count,
                expectedTrackLength: boundary.minimumLength
            )
        }
    }

    func testFractionalExactFitsAndJustBelowBoundariesInEveryStyleAndAxis() {
        let spacedMinimum: CGFloat = 10.1
        let spacedSpacing: CGFloat = 20.1
        let spacedExactFit: CGFloat = 40.3
        XCTAssertEqual(
            CGFloat(2) * spacedMinimum + spacedSpacing,
            spacedExactFit
        )
        assertFractionalBoundaryInEveryStyleAndAxis(
            minimumLength: spacedMinimum,
            spacing: spacedSpacing,
            availableLength: spacedExactFit,
            expectedTracksCount: 2
        )
        assertFractionalBoundaryInEveryStyleAndAxis(
            minimumLength: spacedMinimum,
            spacing: spacedSpacing,
            availableLength: spacedExactFit.nextDown,
            expectedTracksCount: 1
        )

        let zeroSpacingMinimum: CGFloat = 100.1
        let zeroSpacingExactFit: CGFloat = 400.4
        XCTAssertEqual(
            CGFloat(4) * zeroSpacingMinimum,
            zeroSpacingExactFit
        )
        assertFractionalBoundaryInEveryStyleAndAxis(
            minimumLength: zeroSpacingMinimum,
            spacing: 0,
            availableLength: zeroSpacingExactFit,
            expectedTracksCount: 4
        )
        assertFractionalBoundaryInEveryStyleAndAxis(
            minimumLength: zeroSpacingMinimum,
            spacing: 0,
            availableLength: zeroSpacingExactFit.nextDown,
            expectedTracksCount: 3
        )
    }

    func testLargeAndZeroSpacingInEveryStyleAndAxis() {
        // Two minimum-sized tracks leave only 50 points for a 200-point gap.
        assertEveryGridStyle(
            tracks: .fixed(100),
            spacing: 200,
            availableLength: 250,
            expectedTracksCount: 1,
            expectedTrackLength: 100
        )
        assertEveryGridStyle(
            tracks: .min(100),
            spacing: 200,
            availableLength: 250,
            expectedTracksCount: 1,
            expectedTrackLength: 250
        )

        // Zero spacing retains the original floor(available / minimum) count.
        assertEveryGridStyle(
            tracks: .fixed(100),
            spacing: 0,
            availableLength: 250,
            expectedTracksCount: 2,
            expectedTrackLength: 100
        )
        assertEveryGridStyle(
            tracks: .min(100),
            spacing: 0,
            availableLength: 250,
            expectedTracksCount: 2,
            expectedTrackLength: 125
        )
    }

    func testFixedAndMinimumTrackSizingInvariants() {
        let availableLengths: [CGFloat] = [
            0, 50, 99.5, 100, 100.25, 199.5, 200, 210, 219.5, 220, 339.5, 340, 1000.75
        ]
        let spacings: [CGFloat] = [0, 0.5, 20, 175]
        let minimumLength: CGFloat = 100

        for spacing in spacings {
            for availableLength in availableLengths {
                let fixedCount = tracksCount(
                    tracks: .fixed(minimumLength),
                    spacing: spacing,
                    availableLength: availableLength
                )
                let minimumCount = tracksCount(
                    tracks: .min(minimumLength),
                    spacing: spacing,
                    availableLength: availableLength
                )

                XCTAssertEqual(fixedCount, minimumCount)
                XCTAssertGreaterThanOrEqual(fixedCount, 1)
                XCTAssertEqual(
                    itemLength(tracks: .fixed(minimumLength), spacing: spacing, availableLength: availableLength),
                    minimumLength
                )

                let fixedSpan = CGFloat(fixedCount) * minimumLength + CGFloat(fixedCount - 1) * spacing
                if availableLength >= minimumLength {
                    XCTAssertLessThanOrEqual(fixedSpan, availableLength)
                    let nextFixedSpan = CGFloat(fixedCount + 1) * minimumLength + CGFloat(fixedCount) * spacing
                    XCTAssertGreaterThan(nextFixedSpan, availableLength)
                }

                let expandedLength = itemLength(
                    tracks: .min(minimumLength),
                    spacing: spacing,
                    availableLength: availableLength
                )
                let expandedSpan = CGFloat(minimumCount) * expandedLength + CGFloat(minimumCount - 1) * spacing
                XCTAssertGreaterThanOrEqual(expandedLength, 0)
                XCTAssertEqual(expandedSpan, availableLength, accuracy: 0.000001)

                if availableLength >= minimumLength {
                    XCTAssertGreaterThanOrEqual(expandedLength, minimumLength)
                } else {
                    XCTAssertEqual(expandedLength, availableLength)
                }
            }
        }
    }

    func testCountAndNegativeSpacingCompatibility() {
        XCTAssertEqual(tracksCount(tracks: .count(3), spacing: 20, availableLength: 100), 3)
        XCTAssertEqual(itemLength(tracks: .count(3), spacing: 20, availableLength: 100), 20)
        assertEveryGridStyle(
            tracks: .count(3),
            spacing: 20,
            availableLength: 100,
            expectedTracksCount: 3,
            expectedTrackLength: 20
        )

        // Count adaptive tracks as though spacing were zero, but retain the
        // supplied spacing when positioning and expanding tracks.
        XCTAssertEqual(tracksCount(tracks: .fixed(100), spacing: -20, availableLength: 340), 3)
        XCTAssertEqual(tracksCount(tracks: .min(100), spacing: -20, availableLength: 340), 3)
        XCTAssertEqual(itemLength(tracks: .fixed(100), spacing: -20, availableLength: 340), 100)

        let expandedLength = CGFloat(380.0 / 3.0)
        XCTAssertEqual(
            itemLength(tracks: .min(100), spacing: -20, availableLength: 340),
            expandedLength,
            accuracy: 0.000001
        )
        assertEveryGridStyle(
            tracks: .fixed(100),
            spacing: -20,
            availableLength: 340,
            expectedTracksCount: 3,
            expectedTrackLength: 100
        )
        assertEveryGridStyle(
            tracks: .min(100),
            spacing: -20,
            availableLength: 340,
            expectedTracksCount: 3,
            expectedTrackLength: expandedLength
        )
    }

    func testEmptyPreferencesRemainEmptyForAdaptiveTracks() {
        for axis in [Axis.vertical, Axis.horizontal] {
            for tracks in [Tracks.fixed(100), Tracks.min(100)] {
                let modular = modularStyle(axis: axis, tracks: tracks, spacing: 20, mainLength: 50)
                var modularPreferences = GridPreferences(items: [])
                modular.transform(preferences: &modularPreferences, in: availableSize(axis: axis, crossLength: 210, mainLength: 300))
                XCTAssertEqual(modularPreferences, GridPreferences(items: []))

                let staggered = StaggeredGridStyle(axis, tracks: tracks, spacing: 20)
                var staggeredPreferences = GridPreferences(items: [])
                staggered.transform(preferences: &staggeredPreferences, in: availableSize(axis: axis, crossLength: 210, mainLength: 300))
                XCTAssertEqual(staggeredPreferences, GridPreferences(items: []))
            }
        }
    }

    private func assertFractionalBoundaryInEveryStyleAndAxis(
        minimumLength: CGFloat,
        spacing: CGFloat,
        availableLength: CGFloat,
        expectedTracksCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            tracksCount(
                tracks: .fixed(minimumLength),
                spacing: spacing,
                availableLength: availableLength
            ),
            expectedTracksCount,
            file: file,
            line: line
        )
        XCTAssertEqual(
            tracksCount(
                tracks: .min(minimumLength),
                spacing: spacing,
                availableLength: availableLength
            ),
            expectedTracksCount,
            file: file,
            line: line
        )

        assertEveryGridStyle(
            tracks: .fixed(minimumLength),
            spacing: spacing,
            availableLength: availableLength,
            expectedTracksCount: expectedTracksCount,
            expectedTrackLength: minimumLength,
            file: file,
            line: line
        )

        let expandedLength = itemLength(
            tracks: .min(minimumLength),
            spacing: spacing,
            availableLength: availableLength
        )
        assertEveryGridStyle(
            tracks: .min(minimumLength),
            spacing: spacing,
            availableLength: availableLength,
            expectedTracksCount: expectedTracksCount,
            expectedTrackLength: expandedLength,
            file: file,
            line: line
        )

        let expandedSpan = CGFloat(expectedTracksCount) * expandedLength
            + CGFloat(expectedTracksCount - 1) * spacing
        XCTAssertEqual(expandedSpan, availableLength, accuracy: 0.000001, file: file, line: line)
        if availableLength >= minimumLength {
            XCTAssertGreaterThanOrEqual(expandedLength, minimumLength, file: file, line: line)
        }
    }

    private func assertEveryGridStyle(
        tracks: Tracks,
        spacing: CGFloat,
        availableLength: CGFloat,
        expectedTracksCount: Int,
        expectedTrackLength: CGFloat,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let mainLength = max(50, -spacing + 10)

        for axis in [Axis.vertical, Axis.horizontal] {
            assertLayout(
                style: modularStyle(axis: axis, tracks: tracks, spacing: spacing, mainLength: mainLength),
                availableLength: availableLength,
                mainLength: mainLength,
                spacing: spacing,
                expectedTracksCount: expectedTracksCount,
                expectedTrackLength: expectedTrackLength,
                file: file,
                line: line
            )
            assertLayout(
                style: StaggeredGridStyle(axis, tracks: tracks, spacing: spacing),
                availableLength: availableLength,
                mainLength: mainLength,
                spacing: spacing,
                expectedTracksCount: expectedTracksCount,
                expectedTrackLength: expectedTrackLength,
                file: file,
                line: line
            )
        }
    }

    private func assertLayout<Style: GridStyle>(
        style: Style,
        availableLength: CGFloat,
        mainLength: CGFloat,
        spacing: CGFloat,
        expectedTracksCount: Int,
        expectedTrackLength: CGFloat,
        file: StaticString,
        line: UInt
    ) {
        let itemCount = 6
        var preferences = GridPreferences(items: (0..<itemCount).map {
            GridPreferences.Item(
                id: $0,
                bounds: CGRect(origin: .zero, size: measuredSize(axis: style.axis, mainLength: mainLength))
            )
        })

        style.transform(
            preferences: &preferences,
            in: availableSize(axis: style.axis, crossLength: availableLength, mainLength: mainLength * 10)
        )

        XCTAssertEqual(preferences.items.count, itemCount, file: file, line: line)
        XCTAssertEqual(preferences.items.map { $0.id }, (0..<itemCount).map { AnyHashable($0) }, file: file, line: line)

        for (index, preference) in preferences.items.enumerated() {
            let trackIndex = index % expectedTracksCount
            let expectedOrigin = CGFloat(trackIndex) * (expectedTrackLength + spacing)
            XCTAssertEqual(
                crossOrigin(preference.bounds, axis: style.axis),
                expectedOrigin,
                accuracy: 0.000001,
                file: file,
                line: line
            )
            XCTAssertEqual(
                crossLength(preference.bounds, axis: style.axis),
                expectedTrackLength,
                accuracy: 0.000001,
                file: file,
                line: line
            )
            XCTAssertEqual(
                measuredMainLength(preference.bounds, axis: style.axis),
                mainLength,
                accuracy: 0.000001,
                file: file,
                line: line
            )
        }
    }

    private func modularStyle(axis: Axis, tracks: Tracks, spacing: CGFloat, mainLength: CGFloat) -> ModularGridStyle {
        if axis == .vertical {
            return ModularGridStyle(axis, columns: tracks, rows: .fixed(mainLength), spacing: spacing)
        }
        return ModularGridStyle(axis, columns: .fixed(mainLength), rows: tracks, spacing: spacing)
    }

    private func availableSize(axis: Axis, crossLength: CGFloat, mainLength: CGFloat) -> CGSize {
        if axis == .vertical {
            return CGSize(width: crossLength, height: mainLength)
        }
        return CGSize(width: mainLength, height: crossLength)
    }

    private func measuredSize(axis: Axis, mainLength: CGFloat) -> CGSize {
        if axis == .vertical {
            return CGSize(width: 1, height: mainLength)
        }
        return CGSize(width: mainLength, height: 1)
    }

    private func crossOrigin(_ bounds: CGRect, axis: Axis) -> CGFloat {
        if axis == .vertical {
            return bounds.origin.x
        }
        return bounds.origin.y
    }

    private func crossLength(_ bounds: CGRect, axis: Axis) -> CGFloat {
        if axis == .vertical {
            return bounds.size.width
        }
        return bounds.size.height
    }

    private func measuredMainLength(_ bounds: CGRect, axis: Axis) -> CGFloat {
        if axis == .vertical {
            return bounds.size.height
        }
        return bounds.size.width
    }
}
