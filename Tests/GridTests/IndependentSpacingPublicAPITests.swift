import Grid
import XCTest

final class IndependentSpacingPublicAPITests: XCTestCase {
    func testModularSpacingAPIIsPublicAndBackwardCompatible() {
        var style = ModularGridStyle(
            columns: .count(2),
            rows: .fixed(40),
            crossAxisSpacing: 30,
            mainAxisSpacing: 7
        )

        XCTAssertEqual(style.crossAxisSpacing, 30)
        XCTAssertEqual(style.mainAxisSpacing, 7)
        XCTAssertEqual(style.spacing, 30)

        style.crossAxisSpacing = 12
        XCTAssertEqual(style.crossAxisSpacing, 12)
        XCTAssertEqual(style.mainAxisSpacing, 7)
        XCTAssertEqual(style.spacing, 12)

        style.mainAxisSpacing = 5
        XCTAssertEqual(style.crossAxisSpacing, 12)
        XCTAssertEqual(style.mainAxisSpacing, 5)

        style.axis = .horizontal
        XCTAssertEqual(style.crossAxisSpacing, 12)
        XCTAssertEqual(style.mainAxisSpacing, 5)

        style.spacing = 9
        XCTAssertEqual(style.crossAxisSpacing, 9)
        XCTAssertEqual(style.mainAxisSpacing, 9)

        let legacy = ModularGridStyle(columns: 2, rows: 2, spacing: 4)
        XCTAssertEqual(legacy.crossAxisSpacing, 4)
        XCTAssertEqual(legacy.mainAxisSpacing, 4)

        let defaults = ModularGridStyle(columns: 2, rows: 2)
        XCTAssertEqual(defaults.crossAxisSpacing, 8)
        XCTAssertEqual(defaults.mainAxisSpacing, 8)
    }

    func testStaggeredSpacingAPIIsPublicAndBackwardCompatible() {
        var style = StaggeredGridStyle(
            tracks: .min(100),
            crossAxisSpacing: 20,
            mainAxisSpacing: 6
        )

        XCTAssertEqual(style.crossAxisSpacing, 20)
        XCTAssertEqual(style.mainAxisSpacing, 6)
        XCTAssertEqual(style.spacing, 20)

        style.mainAxisSpacing = -3
        XCTAssertEqual(style.crossAxisSpacing, 20)
        XCTAssertEqual(style.mainAxisSpacing, -3)

        style.crossAxisSpacing = 11
        XCTAssertEqual(style.crossAxisSpacing, 11)
        XCTAssertEqual(style.mainAxisSpacing, -3)
        XCTAssertEqual(style.spacing, 11)

        style.axis = .horizontal
        XCTAssertEqual(style.crossAxisSpacing, 11)
        XCTAssertEqual(style.mainAxisSpacing, -3)

        style.spacing = 2
        XCTAssertEqual(style.crossAxisSpacing, 2)
        XCTAssertEqual(style.mainAxisSpacing, 2)

        let legacy = StaggeredGridStyle(tracks: 3, spacing: 4)
        XCTAssertEqual(legacy.crossAxisSpacing, 4)
        XCTAssertEqual(legacy.mainAxisSpacing, 4)

        let defaults = StaggeredGridStyle(tracks: 3)
        XCTAssertEqual(defaults.crossAxisSpacing, 8)
        XCTAssertEqual(defaults.mainAxisSpacing, 8)
    }
}
